variable "environment" {
  description = "Nome do ambiente (ex: homolog, prod)"
  type        = string
}

variable "image_tag" {
  description = "Tag das imagens Docker no GHCR (ex: homolog, main)"
  type        = string
}

variable "git_branch" {
  description = "Branch do repositório frontend na Vercel (ex: homolog, main)"
  type        = string
}

variable "render_region" {
  description = "Região dos Web Services no Render"
  type        = string
  default     = "oregon"
}

variable "render_plan" {
  description = "Plano dos Web Services no Render (free para custo zero)"
  type        = string
  default     = "free"
}

variable "github_org" {
  description = "Organização GitHub dona dos repositórios e imagens GHCR"
  type        = string
  default     = "codedontblow"
}

variable "neon_org_id" {
  description = "ID da organização no Neon.tech (ex: org-...)"
  type        = string
}

variable "neon_region_id" {
  description = "Região do projeto PostgreSQL 16 no Neon"
  type        = string
  default     = "aws-us-east-1"
}

variable "db_name" {
  description = "Nome do banco de dados PostgreSQL"
  type        = string
  default     = "camplana"
}

variable "lana_db_password" {
  description = "Senha da role somente leitura lana_leitura no PostgreSQL"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Chave secreta JWT do DomRock-Backend (mínimo 32 caracteres)"
  type        = string
  sensitive   = true
}

variable "ai_provider" {
  description = "Provedor principal de LLM da Lana (GEMINI, OPENROUTER ou GROQ)"
  type        = string
  default     = "GEMINI"
}

variable "ai_model" {
  description = "Modelo principal de LLM da Lana"
  type        = string
  default     = "gemini-2.5-flash-lite"
}

variable "gemini_api_key" {
  description = "Chave da API Gemini"
  type        = string
  sensitive   = true
  default     = ""
}

variable "groq_api_key" {
  description = "Chave da API Groq"
  type        = string
  sensitive   = true
  default     = ""
}

variable "openrouter_api_key" {
  description = "Chave da API OpenRouter"
  type        = string
  sensitive   = true
  default     = ""
}

variable "langfuse_public_key" {
  description = "Chave pública do Langfuse Cloud"
  type        = string
  sensitive   = true
  default     = ""
}

variable "langfuse_secret_key" {
  description = "Chave secreta do Langfuse Cloud"
  type        = string
  sensitive   = true
  default     = ""
}

variable "langfuse_host" {
  description = "Endpoint do Langfuse Cloud"
  type        = string
  default     = "https://cloud.langfuse.com"
}

variable "otel_exporter_otlp_endpoint" {
  description = "Endpoint OTLP HTTP do Grafana Cloud Free"
  type        = string
  default     = ""
}

variable "otel_exporter_otlp_headers" {
  description = "Headers de autenticação OTLP HTTP (ex: Authorization=Basic ...)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "extra_cors_origins" {
  description = "Origens extras para CORS além da URL padrão do projeto Vercel"
  type        = list(string)
  default     = []
}
