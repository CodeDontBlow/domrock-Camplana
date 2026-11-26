# Manual de Instalação — Camplana

Este manual sobe a stack completa do Camplana (PostgreSQL, backend Spring Boot, Lana e frontend Vue) com Docker Compose, do clone até o login com os usuários de demonstração. Vale para a versão do fim da Sprint 3.

> **Testado do zero em 25/11/2026:** clone novo deste repositório, submódulos na `develop`, volumes do Docker vazios, Linux (Debian 13) com Docker Engine 29 e Compose v2. As 14 migrations subiram sem erro e o `seed-demo.sh` terminou em cerca de 3 minutos.

> **Atalho para a apresentação:** com o `.env` configurado (seção 4), `./scripts/start-demo.sh` faz as seções 5 e 6 de uma vez: sobe os containers, espera o backend e a Lana, carrega a base e os pedidos de exemplo em Solicitações e testa uma resposta da Lana. `--reset` recomeça do zero. Veja [Demo da Sprint 3 em um comando](../../README.md#-demo-da-sprint-3-em-um-comando).

---

## 1. Visão geral

O repositório raiz junta os três projetos como submódulos e sobe tudo com um único `docker compose`:

```text
domrock-camplana/
├── DomRock-Backend/     # API REST: Java 17, Spring Boot, Flyway
├── DomRock-Frontend/    # Interface web: Vue 3, Vite, Pinia
├── DomRock-Lana/        # Agente de IA: Python 3.12, FastAPI, LangGraph, gRPC
├── docker-compose.yml   # Os 4 containers: postgres, backend, lana e frontend
├── .env.example         # Modelo das variáveis de ambiente
├── scripts/             # Carga da base e seed da demonstração
└── docs/                # Manuais, contratos e documentação técnica
```

| Container | O que faz | Porta no host (padrão) |
|---|---|---|
| `postgres-camplana` | Banco PostgreSQL 16 | `5432` |
| `camplana-backend` | API REST e migrations do banco | `8080` |
| `camplana-lana` | Lana: HTTP (simulação) e gRPC (chat) | `8000` e `50051` |
| `camplana-frontend` | Aplicação web (servidor do Vite) | `5173` |

Não é preciso instalar Java, Node nem Python: tudo roda em containers.

---

## 2. Pré-requisitos

- **Git**;
- **Docker** com o plugin **Compose v2** (`docker compose`, com espaço);
- Uma **chave de API de IA** para a Lana: Gemini (gratuita no [Google AI Studio](https://aistudio.google.com/apikey)), OpenRouter ou Groq;
- Uns **5 GB livres** em disco para as imagens e os volumes;
- Um terminal **bash** para os scripts de `scripts/` (no Windows, use o Git Bash ou o WSL).

### 2.1 Linux (Ubuntu, Debian, Linux Mint)

```bash
sudo apt update
sudo apt install -y git curl ca-certificates gnupg

# Repositório oficial do Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# No Linux Mint, usa a versão do Ubuntu em que ele se baseia.
# No Debian, troque "ubuntu" por "debian" nas duas URLs.
UBUNTU_CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Rodar o Docker sem sudo (vale a partir do próximo login; newgrp aplica já neste terminal)
sudo usermod -aG docker $USER
newgrp docker
```

### 2.2 Windows e macOS

Instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/). No Windows, deixe o backend **WSL 2** ligado (é o padrão) e rode os comandos deste manual no **Git Bash** ou num terminal do WSL, porque os scripts de `scripts/` são bash.

### 2.3 Conferir

```bash
git --version
docker compose version
```

---

## 3. Clonar o repositório com os submódulos

```bash
git clone https://github.com/codedontblow/domrock-camplana.git
cd domrock-camplana

# Baixa backend, frontend e Lana na branch develop (definida no .gitmodules)
git submodule update --init --remote
```

Confira que as três pastas `DomRock-*` têm arquivos. Se alguma estiver vazia, o `git submodule update` não terminou: rode de novo.

---

## 4. Configurar o `.env`

```bash
cp .env.example .env
```

Abra o `.env` e preencha a IA. Exemplo com o Gemini:

```ini
AI_PROVIDER=GEMINI
AI_MODEL=gemini-3.5-flash-lite
GEMINI_API_KEY=sua_chave_aqui
```

O resto já vem com valores que funcionam para a demonstração:

| Variável | Para que serve | Padrão |
|---|---|---|
| `DB_USERNAME`, `DB_PASSWORD` | Usuário e senha do PostgreSQL | `postgres` / `postgres` |
| `LANA_DB_PASSWORD` | Senha do papel `lana_leitura`, com que a Lana lê o banco só para leitura | `lana_leitura` |
| `JWT_SECRET` | Chave dos tokens de login (mínimo de 32 caracteres) | valor de desenvolvimento: troque fora da demo |
| `AI_FALLBACKS` | Modelos de reserva, em ordem, se o principal falhar (ex.: cota 429) | Gemini, OpenRouter e Groq; provedor sem chave é ignorado |
| `AI_TIMEOUT_S` | Segundos por modelo antes de passar ao próximo | `30` |

### 4.1 Portas ocupadas

Se uma porta padrão já estiver em uso na sua máquina, descomente a linha correspondente no `.env` e troque o número. O caso mais comum é um PostgreSQL instalado na máquina, que já ocupa a `5432`:

```ini
POSTGRES_HOST_PORT=5434
```

| Variável | Padrão | Serviço |
|---|---|---|
| `POSTGRES_HOST_PORT` | `5432` | PostgreSQL |
| `BACKEND_HOST_PORT` | `8080` | API do backend |
| `LANA_HOST_PORT` | `8000` | HTTP da Lana |
| `LANA_GRPC_HOST_PORT` | `50051` | gRPC da Lana |
| `FRONTEND_HOST_PORT` | `5173` | Aplicação web |

Trocar a porta do host não muda nada entre os containers: eles se falam pela rede interna do Compose.

---

## 5. Subir a stack

```bash
docker compose up -d --build
```

Na primeira vez, o Docker baixa as imagens base e as dependências do Maven, do npm e do pip: leva alguns minutos, conforme a internet. Nas seguintes, o build usa o cache e a stack sobe em cerca de 1 a 2 minutos.

Acompanhe até o backend terminar as migrations:

```bash
docker compose logs -f backend
```

Ele está pronto quando aparece `Successfully applied 14 migrations` (na primeira subida) e, logo depois, `Started CamplanaApplication`. Confira os containers:

```bash
docker compose ps
```

Os quatro devem estar `Up`, e o `postgres-camplana` como `healthy`.

### 5.1 O que as migrations criam

O Flyway do backend aplica as migrations sozinho a cada subida, só as que ainda faltam:

| Migration | O que cria |
|---|---|
| V1 | Base de dados da Dom Rock: funcionários, lojas, marcas, cargos, vendas e % de comissão |
| V2 | Tabela de usuários do sistema |
| V3 | Papel `lana_leitura`, só leitura, que a Lana usa para consultar o banco |
| V4 | Usuários de demonstração (Gabriela, Sérgio, Sílvia e Ana) |
| V5 | Importações mensais da base (jobs e relatório de pendências) |
| V6 | Intercorrências de RH (afastamentos, férias, desligamentos) |
| V7 | Campanhas, versões congeladas e log de status |
| V8, V9 | Simulações e o vínculo da simulação com a versão |
| V10 | Histórico do chat com a Lana |
| V11 | Solicitações de correção da base, com aprovação (Sprint 3) |
| V12 | Perfil **Auditor** e o usuário Paulo (Sprint 3) |
| V13 | Leitura das intercorrências pela Lana, para a apuração (Sprint 3) |
| V14 | Alertas técnicos que travam a aprovação (Sprint 3) |

### 5.2 Sandbox do código gerado

Na simulação, a Lana gera o código Python da regra e o executa num processo isolado, com limites de memória, CPU, disco e tempo. Esses limites usam recursos do Linux, então valem dentro do container da Lana sem nenhuma configuração.

Se a Lana rodar fora do Docker num sistema sem esses recursos (Windows sem WSL), o código ainda roda, mas só o limite de tempo continua valendo. O log da Lana avisa com a mensagem `Sandbox sem limites de memória, CPU e disco`.

---

## 6. Carregar os dados da demonstração

Com a stack no ar, na raiz do repositório:

```bash
./scripts/seed-demo.sh
```

O script leva cerca de 3 minutos e faz, em ordem:

1. espera o backend responder;
2. importa a base da Dom Rock de **julho a dezembro de 2025** (RH, vendas e comissão), a partir das planilhas que vêm no submódulo do backend;
3. carrega as intercorrências de RH do período e gera o relatório de pendências em `docs/relatorio-pendencias-intercorrencias.md`;
4. cria as campanhas da demonstração em vários status (rascunho, aguardando aprovação, aprovada, reprovada e arquivada), com conversas e simulações.

Para voltar só as campanhas da demonstração ao estado inicial, sem reimportar as planilhas (leva segundos):

```bash
./scripts/seed-demo.sh --so-campanhas
```

O `--so-campanhas` recria apenas as campanhas da demonstração: as campanhas criadas por você continuam no banco.

> Se você mudou `BACKEND_HOST_PORT`, passe a URL do backend: `./scripts/seed-demo.sh http://localhost:<porta>`.

---

## 7. Acessar o sistema

Abra **http://localhost:5173** (ou a porta que você definiu em `FRONTEND_HOST_PORT`).

Todos os usuários de demonstração usam a senha **`123456`**:

| Nome | E-mail | Perfil | O que faz no sistema |
|---|---|---|---|
| Gabriela | `gabriela@camplana.com.br` | Gerente | Cria campanhas conversando com a Lana, simula e publica para aprovação |
| Sérgio | `sergio@camplana.com.br` | Supervisor | Tudo da Gerente, mais aprovar ou devolver campanhas e importar a base mensal |
| Sílvia | `silvia@camplana.com.br` | Supervisor | Igual ao Sérgio (útil para testar a aprovação por outra pessoa) |
| Paulo | `paulo@camplana.com.br` | Auditor | Consulta tudo sem alterar nada; abre e resolve alertas técnicos |
| Ana | `ana@camplana.com.br` | Administrador | Só gestão de usuários |

O passo a passo de cada perfil está no [Manual do Usuário](manual-usuario.md).

---

## 8. Atualizar para uma versão nova

```bash
git pull
git submodule update --init --remote
docker compose up -d --build
```

As migrations novas rodam sozinhas quando o backend sobe. Os dados do banco ficam no volume e não se perdem.

---

## 9. Desligar e recomeçar do zero

```bash
docker compose down        # para os containers e mantém os dados
docker compose down -v     # para e APAGA o banco (volume postgres-data)
```

Depois de um `down -v`, suba de novo (seção 5) e rode o `seed-demo.sh` completo (seção 6).

---

## 10. Rodar um serviço fora do Docker (desenvolvimento)

Para depurar um serviço isolado, deixe o banco no Compose (`docker compose up -d postgres`) e rode o serviço na máquina:

- **Backend** (Java 17): `cd DomRock-Backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev`
- **Frontend** (Node 22 ou 24): `cd DomRock-Frontend && npm install && npm run dev`
- **Lana** (Python 3.12): `cd DomRock-Lana && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt && uvicorn main:app --host 0.0.0.0 --port 8000 --reload`

Cada projeto tem no próprio README as variáveis de ambiente que espera fora do Compose.

---

## 11. Problemas comuns

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| `Bind for 0.0.0.0:5432 failed: port is already allocated` | Outro serviço usa a porta | Troque a porta no `.env` (seção 4.1) e rode `docker compose up -d` de novo |
| `Conflict. The container name "/postgres-camplana" is already in use` | Sobrou um container de outra cópia do projeto | `docker rm postgres-camplana` (só remove o container parado; os dados ficam no volume) |
| `defina AI_PROVIDER (GEMINI \| OPENROUTER) no .env` | `.env` sem a IA | Preencha `AI_PROVIDER`, `AI_MODEL` e a chave (seção 4) |
| Login não responde | O backend ainda está aplicando as migrations | Espere o `Started CamplanaApplication` em `docker compose logs backend` |
| Pasta `DomRock-*` vazia ou build falha no `COPY` | Submódulos não baixados | `git submodule update --init --remote` |
| A Lana responde com erro de cota (429) | Cota gratuita do modelo acabou | A cadeia `AI_FALLBACKS` tenta os próximos modelos sozinha. Para a demo sem IA na simulação, crie `DomRock-Lana/.env` com `CODEGEN_MODO=modelo` e rode `docker compose restart lana`: a simulação passa a usar o código de referência |
| `seed-demo.sh: Permission denied` | Script sem permissão de execução | `chmod +x scripts/*.sh` ou rode com `bash scripts/seed-demo.sh` |
