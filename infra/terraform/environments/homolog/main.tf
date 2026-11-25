module "camplana" {
  source = "../../modules/camplana_stack"

  environment = "homolog"
  image_tag   = "homolog"
  git_branch  = "homolog"
  render_plan = "free"

  github_owner                = var.github_owner
  neon_org_id                 = var.neon_org_id
  lana_db_password            = var.lana_db_password
  jwt_secret                  = var.jwt_secret
  ai_provider                 = var.ai_provider
  ai_model                    = var.ai_model
  gemini_api_key              = var.gemini_api_key
  groq_api_key                = var.groq_api_key
  openrouter_api_key          = var.openrouter_api_key
  langfuse_public_key         = var.langfuse_public_key
  langfuse_secret_key         = var.langfuse_secret_key
  otel_exporter_otlp_endpoint = var.otel_exporter_otlp_endpoint
  otel_exporter_otlp_headers  = var.otel_exporter_otlp_headers
}
