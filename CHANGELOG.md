# Changelog

Todas as mudanças notáveis do projeto **Dom Rock / Camplana** (repositório guarda-chuva e submódulos `DomRock-Backend`, `DomRock-Lana` e `DomRock-Frontend`) são documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.3.0] - Sprint 3 (2026-11-04 a 2026-11-21)

- **`DomRock-Backend`**: endpoint público `GET /api/health` (`HealthController`) retornando `{"status": "UP"}` (`HTTP 200`) para probes de disponibilidade no Render.
- **`DomRock-Backend`**: suporte a transporte HTTP (`LANA_CHAT_TRANSPORT=http`) no `LanaClient` via `POST ${LANA_URL}/agent/invoke`, mantendo `grpc` como padrão local.
- **`DomRock-Backend`**: configuração de CORS parametrizável por ambiente via `CORS_ALLOWED_ORIGINS` (padrão `http://localhost:5173`).
- **`docs/infra/`**: adicionados `ARCHITECTURE_AUDIT.md`, `CHANGELOG_INFRA.md` e `DEPLOY_GUIDE.md` com auditoria técnica, matriz de variáveis de ambiente, guia de secrets e registro cronológico de infraestrutura.
- **`DomRock-Lana` e `DomRock-Backend`**: observabilidade leve opcional via OpenTelemetry OTLP HTTP (Grafana Cloud Free) e Langfuse Cloud (tracing LangGraph/LLM).
- **`infra/terraform/` e `.github/workflows/deploy-homolog.yml`**: IaC modular (`Neon + Render + Vercel`) e pipeline de build/push no GHCR + deploy automatizado para `homolog`.
- **Contratos e Documentação (`domrock-Camplana`)**: definição do backlog da Sprint 3, contrato 2.3 com `apuracao_por_pessoa` e contagens reais das regras base.
- **Alinhamento Organizacional**: atualização dos submódulos e documentação de gRPC entre `DomRock-Backend`, `DomRock-Lana` e `DomRock-Frontend` apontando para a organização `codedontblow`.

### Changed

- **`DomRock-Backend/Dockerfile`**: `ENTRYPOINT` atualizado para `["sh", "-c", "java $JAVA_OPTS -jar app.jar"]`, permitindo ajuste dinâmico de memória JVM em containers de 512 MB RAM.
- **`DomRock-Lana/Dockerfile`**: removida a flag `--reload` do `CMD` padrão de produção e adicionado usuário não-root `appuser` com propriedade sobre `/app`.
- **`docker-compose.yml`**: adicionado `command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload` no serviço `lana` para preservar o hot-reload em desenvolvimento local.
- **`DomRock-Backend` (`V3__create_role_lana_leitura.sql`)**: criação, `ALTER ROLE` e `GRANT` da role `lana_leitura` protegidos contra `insufficient_privilege` / `undefined_object` para compatibilidade com PostgreSQL gerenciado (Neon/Supabase).

---

## [0.2.0] - Sprint 2 (2026-10-07 a 2026-10-28)

### Added

- **`DomRock-Backend`**:
  - Fluxo completo de decisão e aprovação de campanhas (`POST /api/campanhas/*/decidir`, fila de aprovação e histórico de versões).
  - Re-simulação de versões com intercorrências de RH (`V6__create_evento_rh.sql`, `V7__create_campanha.sql`, `V8__create_simulacao.sql`, `V9__add_versao_na_simulacao.sql`).
  - Persistência de conversas e envio de histórico para a Lana (`V10__create_mensagem_chat.sql`).
  - Importação isolada da planilha de Comissão e relatório de pendências.
- **`DomRock-Lana`**:
  - Operação stateless com reconstrução de contexto via histórico enviado pelo Backend.
  - Trilha de auditoria (`trilha` e `events`) indicando a origem de cada número no chat e na simulação.
  - Cálculo de comissão vigente por marca e cargo com histórico e detecção de conflitos.
  - Resultado estruturado em blocos (Meta, Comissão, Orçamento).
- **`DomRock-Frontend`**:
  - Telas de gestão de usuários, importação de bases e relatório de pendências.
  - Fila de aprovação para Supervisor, "Minhas campanhas" para Gerente e painel de decisão com interferências reais.
  - Reabertura de conversa da campanha no chat e polling de status da simulação.
- **`domrock-Camplana`**:
  - Seed de demonstração (`scripts/seed-demo.sh`) com 9 campanhas, simulações reais e conversas gravadas, além de script de carga de intercorrências de RH.

---

## [0.1.0] - Sprint 1 (2026-09-11 a 2026-10-03)

### Added

- **Setup Inicial e Orquestração**: estruturação inicial com Java 17 / Spring Boot, Python 3.12 / FastAPI, Vue 3 / Vite, PostgreSQL 16 e `docker-compose.yml` unificado.
- **`DomRock-Backend`**: migrações base (`V1` a `V5`), autenticação JWT por perfil (`ADMIN`, `GERENTE`, `SUPERVISOR`), cliente gRPC para o chat da Lana e cliente HTTP para simulação.
- **`DomRock-Lana`**: servidor gRPC integrado ao ciclo de vida do FastAPI, cadeia de fallback entre provedores externos de LLM (`GEMINI`, `OPENROUTER`, `GROQ`), sandbox isolado em subprocesso (`SubprocessRunner`) e pipeline de CI no GitHub Actions.
- **`DomRock-Frontend`**: interface de chat com a Lana, revisão/edição de parâmetros extraídos e visualização inicial de simulação.
