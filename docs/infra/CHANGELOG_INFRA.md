# Changelog de Infraestrutura (`domrock-Camplana`)

Todas as alterações notáveis de infraestrutura, containers e orquestração são documentadas neste arquivo, seguindo o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Unreleased]

### Fixed
- **`infra/terraform/environments/{homolog,prod}/providers.tf` e `modules/camplana_stack/versions.tf`**:
  - Adicionado o bloco `terraform { required_providers { ... } }` (`render-oss/render`, `vercel/vercel`, `kislerdm/neon`) também nos módulos raiz `homolog` e `prod`, mantendo `modules/camplana_stack/versions.tf` apenas com `required_providers` (sem blocos `provider`).
  - **Por quê:** sem `required_providers` no módulo raiz, o `terraform init` tentava resolver `provider "render"`, `provider "vercel"` e `provider "neon"` no namespace padrão `hashicorp/*`.

### Changed
- **`infra/terraform/` (`backend.tf`), `.github/workflows/deploy-homolog.yml` e `docs/infra/DEPLOY_GUIDE.md`**:
  - Removido o bloco `cloud` (HCP Terraform) e a dependência de `TF_API_TOKEN`, passando a usar o backend `local` do Terraform.
  - O workflow `deploy-homolog.yml` agora restaura e persiste o `terraform.tfstate` na branch dedicada e isolada `tfstate-homolog` usando apenas `GITHUB_TOKEN`.
  - **Por quê:** eliminar a dependência de organização gratuita no HCP Terraform mantendo persistência gratuita e segura do estado entre execuções de CI/CD.
- **`DomRock-Backend` (`V3__create_role_lana_leitura.sql`)**:
  - Envolvidos a criação, `ALTER ROLE` e `GRANT` da role `lana_leitura` em blocos `DO $$ ... EXCEPTION WHEN insufficient_privilege ... END $$;`.
  - **Por quê:** garantir idempotência e evitar falha de migração do Flyway em bancos PostgreSQL gerenciados (Neon/Supabase) onde o usuário da aplicação não possui privilégio `CREATEROLE`.
- **`DomRock-Backend/Dockerfile`**:
  - Alterado o `ENTRYPOINT` de `["java", "-jar", "app.jar"]` para `["sh", "-c", "java $JAVA_OPTS -jar app.jar"]`.
  - **Por quê:** permitir a injeção dinâmica de flags da JVM (como `-Xmx320m -Xms128m` ou `-XX:MaxRAMPercentage=70.0`) em ambiente de homologação com limite de 512 MB RAM (Render Free) sem necessidade de rebuild da imagem. Mantido o usuário não-root `spring`.
- **`DomRock-Lana/Dockerfile`**:
  - Removida a flag `--reload` do `CMD` padrão (`uvicorn main:app --host 0.0.0.0 --port 8000`).
  - **Por quê:** em produção/homologação, o `--reload` consome recursos extras com file watchers e é inadequado para execução estável com 1 worker em containers de 512 MB RAM.
- **`docker-compose.yml` (raiz)**:
  - Adicionado `command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload` especificamente ao serviço `lana`.
  - **Por quê:** preservar o hot-reload automático no fluxo de desenvolvimento local agora que o `Dockerfile` da Lana usa comando de produção.

### Security
- **`DomRock-Lana/Dockerfile`**:
  - Criado usuário de sistema sem privilégios (`appuser`) com propriedade sobre `/app` (`chown -R appuser:appuser /app`) e definido `USER appuser` antes da inicialização do `uvicorn`.
  - **Por quê:** eliminar a execução como `root` dentro do container da IA, seguindo o princípio do menor privilégio e alinhando ao padrão já adotado no `DomRock-Backend`.

### Added
- **`DomRock-Lana` (`requirements.txt`, `app/core/observability.py`, `main.py`, `app/agent/service.py`)**:
  - Adicionados `langfuse` e pacotes OpenTelemetry (`opentelemetry-api`, `opentelemetry-sdk`, `opentelemetry-exporter-otlp-proto-http`, `opentelemetry-instrumentation-fastapi`).
  - Instrumentação OTLP HTTP ativada apenas se `OTEL_EXPORTER_OTLP_ENDPOINT` estiver definida; callback do Langfuse ativado apenas se `LANGFUSE_PUBLIC_KEY` e `LANGFUSE_SECRET_KEY` estiverem definidas.
  - **Por quê:** observabilidade de LLM/LangGraph e traces HTTP sem container de agente local e sem impacto em dev local.
- **`DomRock-Backend` (`pom.xml`, `application.properties`)**:
  - Adicionados `spring-boot-starter-actuator` e `micrometer-registry-otlp` com exportação OTLP HTTP desabilitada por padrão (`OTEL_METRICS_ENABLED=false`).
  - **Por quê:** enviar métricas ao Grafana Cloud Free diretamente via OTLP HTTP em `homolog`/`prod`, mantendo o footprint reduzido dentro dos 512 MB RAM.
- **`infra/terraform/`**:
  - Criado módulo reutilizável `modules/camplana_stack` e ambientes `environments/homolog` e `environments/prod` integrando `kislerdm/neon`, `render-oss/render` e `vercel/vercel`.
- **`.github/workflows/deploy-homolog.yml` e `docs/infra/DEPLOY_GUIDE.md`**:
  - Pipeline CI/CD para build/push no GHCR, `terraform apply` e disparo de Deploy Hooks no Render, acompanhado do guia de operação e lista de GitHub Secrets.
- **`DomRock-Backend` (`HealthController.java` + `SecurityConfig.java`)**:
  - Criado endpoint público `GET /api/health` retornando `{"status": "UP"}` (`HTTP 200`) e liberado no `SecurityConfig` com `permitAll()`.
  - **Por quê:** atender aos healthchecks do load balancer do Render sem autenticação JWT e sem adicionar o overhead de memória do `spring-boot-starter-actuator` em containers de 512 MB RAM.
- **`DomRock-Backend` (`SecurityConfig.java`, `application.properties`, `application-dev.properties`)**:
  - Adicionada configuração global de CORS via `CorsConfigurationSource` parametrizada por `CORS_ALLOWED_ORIGINS` (padrão `http://localhost:5173`).
  - **Por quê:** permitir requisições do Frontend hospedado na Vercel em `homolog`/`prod` sem hardcode de domínios.
- **`DomRock-Backend` (`LanaClient.java`, `application.properties`, `application-dev.properties`)**:
  - Adicionado suporte a transporte HTTP (`LANA_CHAT_TRANSPORT=http`) via `RestClient` para `POST ${LANA_URL}/agent/invoke`, mantendo `grpc` como padrão.
  - **Por quê:** no Render Free Tier, Web Services gratuitos expõem apenas HTTP/HTTPS (sem gRPC raw na porta `50051`); a chave permite alternar para HTTPS em nuvem sem quebrar o gRPC local.
- **`docs/infra/ARCHITECTURE_AUDIT.md`**:
  - Documentação viva da auditoria técnica dos três submódulos (`DomRock-Backend`, `DomRock-Lana`, `DomRock-Frontend`), matriz de variáveis de ambiente, diagnóstico de consumo de memória/sandbox da IA, requisitos do PostgreSQL 16 e estado dos endpoints de healthcheck.
- **`docs/infra/CHANGELOG_INFRA.md`**:
  - Registro cronológico das alterações de infraestrutura aplicadas nesta etapa.
