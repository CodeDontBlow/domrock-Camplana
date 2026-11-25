terraform {
  required_version = ">= 1.6.0"

  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.3"
    }
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.0"
    }
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.6"
    }
  }
}

# Lê automaticamente RENDER_API_KEY e RENDER_OWNER_ID do ambiente
provider "render" {}

# Lê automaticamente VERCEL_API_TOKEN do ambiente
provider "vercel" {}

# Lê automaticamente NEON_API_KEY do ambiente
provider "neon" {}
