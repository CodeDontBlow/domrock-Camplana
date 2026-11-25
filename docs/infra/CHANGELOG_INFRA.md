# Changelog de Infraestrutura (`domrock-Camplana`)

Todas as alterações notáveis de infraestrutura, containers e orquestração são documentadas neste arquivo, seguindo o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Unreleased]

### Fixed
- **`.github/workflows/deploy-homolog.yml` e `infra/terraform/modules/camplana_stack/main.tf` (Neon State Drift)**:
  - Adicionada limpeza idempotente (`terraform state rm ... || true`) antes do `terraform plan` para `neon_endpoint.env`, `neon_branch.env`, `neon_role.owner` e `neon_database.this` após recriação do projeto Neon.
  - Adicionado `lifecycle { replace_triggered_by = [neon_project.this.id] }` nos recursos filhos do Neon em `main.tf` para garantir recriação em cascata caso `neon_project.this` seja substituído no futuro.
- **`infra/terraform/modules/camplana_stack/main.tf` (`render_web_service.lana` e `render_web_service.backend`)**:
  - Adicionado `lifecycle { ignore_changes = [maintenance_mode] }` nos dois recursos `render_web_service`.
  - **Por quê:** evitar que o provider `render-oss/render` tente atualizar `maintenance_mode` via `PATCH` em serviços do plano `free` (operação restrita a planos pagos).
- **`DomRock-Frontend/vercel.json`, `infra/terraform/modules/camplana_stack/main.tf` e `DomRock-Backend` (CORS)**:
  - Criado `DomRock-Frontend/vercel.json` com rewrite SPA (`/(.*) -> /index.html`) para evitar `404 NOT_FOUND` em rotas diretas como `/login` na Vercel.
  - Adicionado `https://camplana.vercel.app` (junto de `https://domrock-frontend-homolog.vercel.app`) à lista padrão de `CORS_ALLOWED_ORIGINS` no módulo Terraform e no fallback do `DomRock-Backend`.
  - Confirmado que `VITE_API_BASE_URL` (usada pelo Axios em `src/services/api.ts`) já está configurada em `vercel_project_environment_variable.vite_api_base_url` apontando para `render_web_service.backend.url`.
- **`infra/terraform/` (`vercel_project.frontend`) e `.github/workflows/deploy-homolog.yml`**:
  - Adicionada a variável `github_owner` com padrão `"CodeDontBlow"` para o recurso `vercel_project.frontend` (alinhando o case retornado pela API da Vercel), mantendo `github_org = "codedontblow"` em minúsculo para as imagens OCI/Docker no `ghcr.io`.
  - Adicionado passo idempotente de `terraform import` no workflow `deploy-homolog.yml` caso `domrock-frontend-homolog` já exista na Vercel fora do state.
- **`infra/terraform/` (`neon_project.this`) e `.github/workflows/deploy-homolog.yml`**:
  - Adicionada a variável `neon_org_id` no módulo `camplana_stack` e nos ambientes `homolog` e `prod`, mapeando `org_id = var.neon_org_id` em `neon_project.this` e injetando `TF_VAR_neon_org_id` via secret `NEON_ORG_ID` no GitHub Actions.
  - **Por quê:** o provider `kislerdm/neon` (v0.18.0) exige `org_id` na criação do recurso `neon_project`.
- **`infra/terraform/environments/{homolog,prod}/providers.tf` e `modules/camplana_stack/versions.tf`**:
  - Adicionado o bloco `terraform { required_providers { ... } }` (`render-oss/render`, `vercel/vercel`, `kislerdm/neon`) também nos módulos raiz `homolog` e `prod`, mantendo `modules/camplana_stack/versions.tf` apenas com `required_providers` (sem blocos `provider`).
  - **Por quê:** sem `required_providers` no módulo raiz, o `terraform init` tentava resolver `provider "render"`, `provider "vercel"` e `provider "neon"` no namespace padrão `hashicorp/*`.

### Changed
- **`DomRock-Lana` (`app/core/config.py`, `.env.example`), `infra/terraform/` e `docs/infra/DEPLOY_GUIDE.md`**:
  - Alterado o provedor LLM padrão da Lana de Google Gemini para **Groq** (`AI_PROVIDER=GROQ`, `AI_MODEL=llama-3.3-70b-versatile` via `langchain-groq` / `ChatGroq` e `GROQ_API_KEY`), mantendo suporte opcional de fallback para OpenRouter e Gemini via `AI_FALLBACKS`.
  - Confirmado que `GROQ_API_KEY` já é repassada ao serviço `domrock-lana` no Terraform e no workflow `deploy-homolog.yml`, e que `lifecycle { ignore_changes = [maintenance_mode] }` já está aplicado nos recursos Render.
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
