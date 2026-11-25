# Backend local do Terraform.
# Para automação futura de produção, persistir terraform.tfstate em branch dedicada (ex: tfstate-prod).
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
