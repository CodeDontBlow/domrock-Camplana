# Auditoria Técnica de Arquitetura e Infraestrutura (`homolog` / Custo Zero)

**Data da Auditoria:** 2026-11-25  
**Escopo:** Repositório principal `domrock-Camplana` e submódulos `DomRock-Backend`, `DomRock-Lana` e `DomRock-Frontend`.  
**Alvo de Deploy:** Render Free (512 MB RAM por serviço para Backend e Lana), Vercel (Frontend) e PostgreSQL 16 gerenciado externo (Neon / Supabase).

---

## 1. Visão Geral da Arquitetura Atual

| Componente | Stack | Porta(s) | Comunicação |
| :--- | :--- | :--- | :--- |
| **DomRock-Frontend** | Vue 3 + Vite + Tailwind | `5173` (dev) / estático (Vercel) | HTTP/HTTPS → Backend (`/backend` em dev via proxy Vite, ou URL direta via `VITE_API_BASE_URL`) |
| **DomRock-Backend** | Java 17 + Spring Boot 4.1.1 + Flyway + gRPC/HTTP Client | `8080` (HTTP) | JDBC → PostgreSQL 16; HTTP (`LANA_URL`) ou gRPC (`GRPC_LANA_HOST:GRPC_LANA_PORT`) → Lana |
| **DomRock-Lana** | Python 3.12 + FastAPI + Uvicorn + gRPC Server + LangChain/LangGraph | `8000` (HTTP) + `50051` (gRPC) | `psycopg2` (papel `lana_leitura`) → PostgreSQL 16; HTTPS → APIs de LLM externas |
| **Banco de Dados** | PostgreSQL 16 | `5432` | Gerenciado externamente no ambiente `homolog` (Neon / Supabase) |

> [!NOTE]
> O Frontend **não** se comunica diretamente com a Lana. Toda orquestração de chat e simulação passa pelo Backend.

---

## 2. Diagnóstico por Serviço (Memória, Sandbox, Banco e Healthcheck)

### 2.1 `DomRock-Lana` (Python 3.12)
- **Provedor de LLM e Embeddings:**
  - Utiliza exclusivamente **APIs externas** via LangChain (`GEMINI` via `langchain-google-genai`, `OPENROUTER` via `langchain-openrouter` e `GROQ` via `langchain-groq`), configuradas em `app/core/config.py`.
  - **Não utiliza embeddings** nem modelos locais pesados em RAM (`torch`, `transformers`, `sentence-transformers`, `faiss` não estão presentes em `requirements.txt`). Compatível com o limite de **512 MB RAM** do Render Free.
- **Execução de Código / Sandbox Isolado:**
  - Implementado via `SubprocessRunner` (`app/tools/code_tool/runner.py`) e `harness.py` (`app/tools/code_tool/harness.py`).
  - Executa o código gerado em um subprocesso Python isolado (`python -I -B harness.py <timeout_s>`) com `env={}` e `cwd` em diretório temporário vazio.
  - **Não** acessa `/var/run/docker.sock` nem cria containers irmãos (compatível com Render).
  - Aplica restrições de AST, builtins e imports permitidos (`pandas`, `numpy`, `math`, `datetime`), além de `resource.setrlimit` (`RLIMIT_CPU`, `RLIMIT_FSIZE=0` e `RLIMIT_AS=2 GiB`).
- **Healthcheck e Comunicação em Nuvem:**
  - Rota raiz `GET /` (`main.py`) retorna `200 OK` com `{"status": "lana-ai is running", "grpc": "active on port 50051"}`.
  - Como o Render Free expõe apenas tráfego HTTP/HTTPS externo (sem gRPC raw na porta `50051` entre Web Services gratuitos), o `DomRock-Backend` foi atualizado para suportar `LANA_CHAT_TRANSPORT=http` apontando para `POST ${LANA_URL}/agent/invoke`.

### 2.2 `DomRock-Backend` (Java 17 / Spring Boot)
- **Extensões e Compatibilidade PostgreSQL 16 (Neon/Supabase):**
  - Nenhuma extensão adicional (`pgvector`, `uuid-ossp`, etc.) é exigida nas migrações `V1` a `V10`.
  - A migração `V3__create_role_lana_leitura.sql` foi tornada resiliente com blocos `DO $$ ... EXCEPTION WHEN insufficient_privilege ... END $$;`, evitando falhas caso a role `lana_leitura` já exista ou o usuário de conexão não possua privilégio `CREATEROLE`.
- **Healthcheck:**
  - Criado o endpoint leve `GET /api/health` (`HealthController.java`), retornando `{"status": "UP"}` (`HTTP 200`), liberado com `.permitAll()` em `SecurityConfig.java` para os probes do Render sem adicionar o peso de `spring-boot-starter-actuator` em containers de 512 MB.
- **CORS:**
  - Configurado em `SecurityConfig.java` via `CorsConfigurationSource` parametrizado por `CORS_ALLOWED_ORIGINS` (fallback `http://localhost:5173`), permitindo injetar o domínio da Vercel em `homolog`/`prod`.
- **Comunicação `Backend` ↔ `Lana`:**
  - Simulação: `LanaSimulacaoClient` utiliza HTTP (`RestClient`) via `POST ${LANA_URL}/simulacao`.
  - Chat: `LanaClient` suporta `LANA_CHAT_TRANSPORT=grpc` (padrão local via `IaGrpcClientService`) e `LANA_CHAT_TRANSPORT=http` (via `POST ${LANA_URL}/agent/invoke` para Render Free).
- **Consumo de Memória (512 MB RAM):**
  - O `Dockerfile` aceita `JAVA_OPTS` no `ENTRYPOINT`, permitindo injetar limites como `-Xmx320m -Xms128m -XX:+UseSerialGC`.

### 2.3 `DomRock-Frontend` (Vue 3 / Vercel)
- **Comunicação:** utiliza apenas `VITE_API_BASE_URL` (`src/services/api.ts`, fallback `/backend`). Em dev local, `API_PROXY_TARGET` direciona o proxy do Vite (`vite.config.ts`) para `http://localhost:8080`.

---

## 3. Matriz Final de Variáveis de Ambiente por Serviço

> **Nota:** Valores reais e segredos devem ser injetados exclusivamente via painel do provedor (Render / Vercel) ou `.env` local.

### 3.1 `DomRock-Backend`
| Variável | Obrigatória | Padrão | Descrição / Uso |
| :--- | :---: | :--- | :--- |
| `DB_URL` | Sim | — | URL JDBC PostgreSQL (`jdbc:postgresql://<host>:5432/<db>?sslmode=require`) |
| `DB_USERNAME` | Sim | — | Usuário principal do banco (JPA e Flyway) |
| `DB_PASSWORD` | Sim | — | Senha do usuário principal do banco |
| `LANA_DB_PASSWORD` | Sim | — | Senha da role `lana_leitura` (Flyway V3) |
| `JWT_SECRET` | Sim | — | Segredo de assinatura JWT (mínimo 32 caracteres em homolog/prod) |
| `LANA_URL` | Sim | — | URL HTTP/HTTPS base da Lana (ex.: `https://lana-homolog.onrender.com`) |
| `LANA_CHAT_TRANSPORT` | Não | `grpc` | Transporte do chat: `grpc` (local/rede privada) ou `http` (Render Free via `LANA_URL`) |
| `GRPC_LANA_HOST` | Condicional* | — | Host gRPC da Lana (obrigatório quando `LANA_CHAT_TRANSPORT=grpc`) |
| `GRPC_LANA_PORT` | Condicional* | — | Porta gRPC da Lana (padrão `50051`) |
| `CORS_ALLOWED_ORIGINS` | Não | `http://localhost:5173` | Origens permitidas separadas por vírgula (ex.: URL da Vercel em homolog) |
| `JAVA_OPTS` | Não | — | Flags JVM injetadas no `ENTRYPOINT` (ex.: `-Xmx320m -Xms128m`) |

### 3.2 `DomRock-Lana`
| Variável | Obrigatória | Padrão | Descrição / Uso |
| :--- | :---: | :--- | :--- |
| `AI_PROVIDER` | Sim | — | Provedor principal (`GEMINI`, `OPENROUTER` ou `GROQ`) |
| `AI_MODEL` | Sim | — | Identificador do modelo principal |
| `GEMINI_API_KEY` | Condicional* | — | Chave da API Gemini |
| `OPENROUTER_API_KEY` | Condicional* | — | Chave da API OpenRouter |
| `GROQ_API_KEY` | Condicional* | — | Chave da API Groq |
| `AI_FALLBACKS` | Não | `""` | Cadeia de fallback (`PROVEDOR:modelo,...`) |
| `AI_TIMEOUT_S` | Não | `30` | Timeout por chamada de modelo em segundos |
| `DATABASE_URL` | Sim | — | URI PostgreSQL com usuário `lana_leitura` |
| `CODEGEN_MODO` | Não | `llm` | `llm` (código via IA) ou `modelo` (cálculo fixo determinístico) |
| `PORT` | Não | `8000` | Porta HTTP configurada no `Settings` |

*\* Ao menos a chave correspondente ao `AI_PROVIDER` configurado deve estar preenchida.*

### 3.3 `DomRock-Frontend`
| Variável | Obrigatória | Ambiente | Descrição / Uso |
| :--- | :---: | :--- | :--- |
| `VITE_API_BASE_URL` | Sim | Build (Vercel / Prod) | URL HTTPS pública do Backend no Render (ou `/backend` em dev) |
| `API_PROXY_TARGET` | Não | Apenas Dev (Vite) | Destino do proxy local do Vite (padrão `http://localhost:8080`) |
