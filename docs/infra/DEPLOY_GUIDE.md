# Guia de Deploy e Operação (`homolog` / Custo Zero)

Este guia descreve os segredos necessários, a estrutura Terraform e o procedimento para validar e publicar o ambiente `homolog` do projeto **Dom Rock / Camplana**.

---

## 1. GitHub Secrets Necessários (`domrock-Camplana`)

Cadastre em **Settings → Secrets and variables → Actions** no repositório `domrock-Camplana`:

| Secret | Obrigatório | Origem / Finalidade |
| :--- | :---: | :--- |
| `RENDER_API_KEY` | Sim | API Key da conta Render (`render-oss/render`) |
| `RENDER_OWNER_ID` | Sim | Workspace/Owner ID no Render (ex.: `tea-...` ou `usr-...`) |
| `VERCEL_API_TOKEN` | Sim | Token de API da Vercel (`vercel/vercel`) |
| `NEON_API_KEY` | Sim | API Key da conta Neon.tech (`kislerdm/neon`) |
| `LANA_DB_PASSWORD` | Sim | Senha definida para a role somente leitura `lana_leitura` no PostgreSQL |
| `JWT_SECRET` | Sim | Segredo de assinatura JWT do Backend (mínimo 32 caracteres) |
| `GEMINI_API_KEY` | Condicional* | Chave da API Google Gemini para a Lana |
| `GROQ_API_KEY` | Não | Chave da API Groq (fallback) |
| `OPENROUTER_API_KEY` | Não | Chave da API OpenRouter (fallback) |
| `LANGFUSE_PUBLIC_KEY` | Não | Chave pública do Langfuse Cloud (tracing LLM/LangGraph) |
| `LANGFUSE_SECRET_KEY` | Não | Chave secreta do Langfuse Cloud |
| `GRAFANA_OTLP_ENDPOINT` | Não | Endpoint OTLP HTTP do Grafana Cloud Free (ex.: `https://otlp-gateway-...grafana.net/otlp`) |
| `GRAFANA_OTLP_HEADERS` | Não | Header de autenticação OTLP (ex.: `Authorization=Basic <base64>`) |
| `RENDER_LANA_DEPLOY_HOOK` | Sim** | Deploy Hook URL do serviço `domrock-lana-homolog` no Render |
| `RENDER_BACKEND_DEPLOY_HOOK` | Sim** | Deploy Hook URL do serviço `domrock-backend-homolog` no Render |

*\* Ao menos a chave do provedor configurado em `AI_PROVIDER` (`GEMINI` por padrão).*  
*\*\* Obtidas no painel do Render após o primeiro `terraform apply` criar os serviços.*

> [!IMPORTANT]
> Como o workflow publica imagens no `ghcr.io/codedontblow/*`, certifique-se de que os pacotes `domrock-backend` e `domrock-lana` no GHCR tenham visibilidade **Public** (ou que o Render possua credencial configurada para registry privado).

---

## 2. Validação Local do Terraform (`terraform plan`)

Antes de disparar o pipeline no GitHub Actions:

1. Acesse a pasta do ambiente:
   ```bash
   cd infra/terraform/environments/homolog
   ```
2. Copie o arquivo de exemplo e preencha com credenciais de teste (nunca commitar `terraform.tfvars`):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Exporte os tokens dos provedores no shell:
   ```bash
   export RENDER_API_KEY="..."
   export RENDER_OWNER_ID="..."
   export VERCEL_API_TOKEN="..."
   export NEON_API_KEY="..."
   ```
4. Execute (o backend `local` já vem configurado por padrão em `backend.tf`):
   ```bash
   terraform init
   terraform validate
   terraform plan
   ```

---

## 3. Fluxo Automático (Branch `homolog`)

Ao realizar `push` na branch `homolog` do repositório `domrock-Camplana`:
1. O job `build-and-push` faz checkout recursivo dos submódulos e publica `domrock-backend:homolog` e `domrock-lana:homolog` no `ghcr.io` (com tag adicional do SHA curto).
2. O job `terraform-and-deploy` aplica a infraestrutura em `infra/terraform/environments/homolog` e aciona os Deploy Hooks do Render para atualizar os containers em execução.
