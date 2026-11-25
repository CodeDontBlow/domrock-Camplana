# Backend local do Terraform.
# No CI/CD (.github/workflows/deploy-homolog.yml), o arquivo terraform.tfstate
# é restaurado antes do plan/apply e persistido na branch isolada `tfstate-homolog`.
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
