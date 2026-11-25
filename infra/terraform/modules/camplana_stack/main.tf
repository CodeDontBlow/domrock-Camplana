locals {
  frontend_project_name = "domrock-frontend-${var.environment}"
  frontend_default_url  = "https://${local.frontend_project_name}.vercel.app"
  cors_origins          = join(",", distinct(concat(["https://camplana.vercel.app", local.frontend_default_url], var.extra_cors_origins)))
  otel_enabled          = trimspace(var.otel_exporter_otlp_endpoint) != "" ? "true" : "false"
}

# 1. PostgreSQL 16 gerenciado no Neon.tech
resource "neon_project" "this" {
  name                      = "camplana-${var.environment}"
  org_id                    = var.neon_org_id
  pg_version                = 16
  region_id                 = var.neon_region_id
  history_retention_seconds = 21600
}

resource "neon_branch" "env" {
  project_id = neon_project.this.id
  name       = var.environment
}

resource "neon_endpoint" "env" {
  project_id = neon_project.this.id
  branch_id  = neon_branch.env.id
  type       = "read_write"
}

resource "neon_role" "owner" {
  project_id = neon_project.this.id
  branch_id  = neon_branch.env.id
  name       = "camplana_app"
}

resource "neon_database" "this" {
  project_id = neon_project.this.id
  branch_id  = neon_branch.env.id
  name       = var.db_name
  owner_name = neon_role.owner.name
}

# 2. Motor de IA (DomRock-Lana) no Render Free
resource "render_web_service" "lana" {
  name   = "domrock-lana-${var.environment}"
  plan   = var.render_plan
  region = var.render_region

  health_check_path = "/"

  runtime_source = {
    image = {
      image_url = "ghcr.io/${var.github_org}/domrock-lana"
      tag       = var.image_tag
    }
  }

  env_vars = {
    PORT = { value = "8000" }
    DATABASE_URL = {
      value = "postgresql://lana_leitura:${var.lana_db_password}@${neon_endpoint.env.host}:5432/${neon_database.this.name}?sslmode=require"
    }
    AI_PROVIDER                 = { value = var.ai_provider }
    AI_MODEL                    = { value = var.ai_model }
    GEMINI_API_KEY              = { value = var.gemini_api_key }
    GROQ_API_KEY                = { value = var.groq_api_key }
    OPENROUTER_API_KEY          = { value = var.openrouter_api_key }
    LANGFUSE_PUBLIC_KEY         = { value = var.langfuse_public_key }
    LANGFUSE_SECRET_KEY         = { value = var.langfuse_secret_key }
    LANGFUSE_HOST               = { value = var.langfuse_host }
    OTEL_EXPORTER_OTLP_ENDPOINT = { value = var.otel_exporter_otlp_endpoint }
    OTEL_EXPORTER_OTLP_HEADERS  = { value = var.otel_exporter_otlp_headers }
    OTEL_SERVICE_NAME           = { value = "domrock-lana-${var.environment}" }
  }
}

# 3. Backend Spring Boot (DomRock-Backend) no Render Free
resource "render_web_service" "backend" {
  name   = "domrock-backend-${var.environment}"
  plan   = var.render_plan
  region = var.render_region

  health_check_path = "/api/health"

  runtime_source = {
    image = {
      image_url = "ghcr.io/${var.github_org}/domrock-backend"
      tag       = var.image_tag
    }
  }

  env_vars = {
    JAVA_OPTS                   = { value = "-XX:MaxRAMPercentage=70.0 -XX:+UseSerialGC -Xss512k" }
    LANA_CHAT_TRANSPORT         = { value = "http" }
    LANA_URL                    = { value = render_web_service.lana.url }
    GRPC_LANA_HOST              = { value = "localhost" }
    GRPC_LANA_PORT              = { value = "50051" }
    DB_URL                      = { value = "jdbc:postgresql://${neon_endpoint.env.host}:5432/${neon_database.this.name}?sslmode=require" }
    DB_USERNAME                 = { value = neon_role.owner.name }
    DB_PASSWORD                 = { value = neon_role.owner.password }
    LANA_DB_PASSWORD            = { value = var.lana_db_password }
    JWT_SECRET                  = { value = var.jwt_secret }
    CORS_ALLOWED_ORIGINS        = { value = local.cors_origins }
    OTEL_METRICS_ENABLED        = { value = local.otel_enabled }
    OTEL_EXPORTER_OTLP_ENDPOINT = { value = var.otel_exporter_otlp_endpoint }
    OTEL_EXPORTER_OTLP_HEADERS  = { value = var.otel_exporter_otlp_headers }
  }
}

# 4. Frontend Vue 3 (DomRock-Frontend) na Vercel
resource "vercel_project" "frontend" {
  name      = local.frontend_project_name
  framework = "vite"

  git_repository = {
    type              = "github"
    repo              = "${var.github_owner}/domrock-frontend"
    production_branch = var.git_branch
  }
}

resource "vercel_project_environment_variable" "vite_api_base_url" {
  project_id = vercel_project.frontend.id
  key        = "VITE_API_BASE_URL"
  value      = render_web_service.backend.url
  target     = ["production", "preview"]
}
