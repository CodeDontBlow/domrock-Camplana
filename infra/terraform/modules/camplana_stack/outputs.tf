output "lana_url" {
  description = "URL pública do serviço DomRock-Lana no Render"
  value       = render_web_service.lana.url
}

output "backend_url" {
  description = "URL pública do serviço DomRock-Backend no Render"
  value       = render_web_service.backend.url
}

output "frontend_url" {
  description = "URL padrão do projeto DomRock-Frontend na Vercel"
  value       = local.frontend_default_url
}

output "neon_host" {
  description = "Host do endpoint PostgreSQL 16 no Neon"
  value       = neon_endpoint.env.host
}
