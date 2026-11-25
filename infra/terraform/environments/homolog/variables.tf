variable "github_owner" {
  description = "Owner/Organização GitHub com case exato para a Vercel"
  type        = string
  default     = "CodeDontBlow"
}

variable "neon_org_id" {
  description = "ID da organização no Neon.tech"
  type        = string
}

variable "lana_db_password" {
  type      = string
  sensitive = true
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "ai_provider" {
  type    = string
  default = "GROQ"
}

variable "ai_model" {
  type    = string
  default = "llama-3.3-70b-versatile"
}

variable "gemini_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "groq_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "openrouter_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "langfuse_public_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "langfuse_secret_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "otel_exporter_otlp_endpoint" {
  type    = string
  default = ""
}

variable "otel_exporter_otlp_headers" {
  type      = string
  sensitive = true
  default   = ""
}
