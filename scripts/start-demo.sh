#!/usr/bin/env bash
# Inicia e prepara o ambiente completo para a demonstração da Sprint 3.
# Uso:
#   ./scripts/start-demo.sh [--reset] [--sem-teste-lana]
#
# Opções:
#   --reset            Apaga volumes e dados existentes do compose (solicita confirmação).
#   --sem-teste-lana   Pula o teste de chamada ao vivo do agente Lana na conferência final.
set -euo pipefail

# Resolução da raiz do repositório a partir da localização do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# Flags de execução
DO_RESET=0
SEM_TESTE_LANA=0

for arg in "$@"; do
  case "$arg" in
    --reset)
      DO_RESET=1
      ;;
    --sem-teste-lana)
      SEM_TESTE_LANA=1
      ;;
    -h|--help)
      echo "Uso: $0 [--reset] [--sem-teste-lana]"
      echo ""
      echo "Opções:"
      echo "  --reset            Pergunta antes e executa 'docker compose down -v'"
      echo "  --sem-teste-lana   Pula o teste de invocação ao vivo da Lana no passo 9"
      exit 0
      ;;
    *)
      echo "Erro: Parâmetro desconhecido '$arg'." >&2
      echo "Uso: $0 [--reset] [--sem-teste-lana]" >&2
      exit 1
      ;;
  esac
done

echo "============================================================"
echo "    Camplana - Inicialização da Demonstração (Sprint 3)"
echo "============================================================"

# -----------------------------------------------------------------------------
# [1/9] Pré-requisitos
# -----------------------------------------------------------------------------
echo "[1/9] Verificando pré-requisitos..."

for cmd in git docker curl python3; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Erro: O comando '$cmd' é obrigatório e não foi encontrado." >&2
    echo "Instale '$cmd' em seu sistema operacional e execute novamente." >&2
    exit 1
  fi
done

# Checa se Docker Compose v2 está disponível
if ! docker compose version >/dev/null 2>&1; then
  echo "Erro: O plugin 'docker compose' (v2) não foi encontrado." >&2
  echo "Certifique-se de que o Docker Compose v2 está instalado e tente novamente." >&2
  exit 1
fi

# Checa se o daemon do Docker está rodando
if ! docker info >/dev/null 2>&1; then
  echo "Erro: O serviço do Docker não está rodando ou seu usuário não possui permissão." >&2
  echo "Inicie o daemon do Docker (ex.: 'sudo systemctl start docker' ou abra o Docker Desktop)" >&2
  echo "e confira se seu usuário faz parte do grupo docker ('sudo usermod -aG docker \$USER')." >&2
  exit 1
fi

echo "Pré-requisitos conferidos com sucesso."

# -----------------------------------------------------------------------------
# [2/9] Submódulos Git
# -----------------------------------------------------------------------------
echo "[2/9] Verificando submódulos Git..."

SUBMODULOS=(DomRock-Backend DomRock-Frontend DomRock-Lana)
PRECISA_INIT=0

for sub in "${SUBMODULOS[@]}"; do
  if [ ! -d "$ROOT_DIR/$sub" ] || [ -z "$(ls -A "$ROOT_DIR/$sub" 2>/dev/null)" ]; then
    PRECISA_INIT=1
    break
  fi
done

# Também confere se algum submódulo consta como não inicializado no status do git
if [ "$PRECISA_INIT" -eq 0 ]; then
  if git submodule status 2>/dev/null | grep -q '^-'; then
    PRECISA_INIT=1
  fi
fi

if [ "$PRECISA_INIT" -eq 1 ]; then
  echo "Submódulo(s) vazio(s) detectado(s). Inicializando submódulos nas versões fixadas..."
  git submodule update --init
else
  echo "Submódulos já inicializados."
fi

# Verifica se algum submódulo está em commit diferente do fixado (prefixado com '+')
while IFS= read -r linha; do
  if [ -n "$linha" ] && [ "${linha:0:1}" = "+" ]; then
    nome_sub=$(echo "$linha" | awk '{print $2}')
    echo "Aviso: O submódulo '$nome_sub' está em um commit diferente do fixado no repositório. Mantendo a versão atual."
  fi
done < <(git submodule status 2>/dev/null || true)

# -----------------------------------------------------------------------------
# [3/9] Arquivo .env
# -----------------------------------------------------------------------------
echo "[3/9] Validando configuração (.env)..."

ENV_FILE="$ROOT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  if [ -f "$ROOT_DIR/.env.example" ]; then
    cp "$ROOT_DIR/.env.example" "$ENV_FILE"
    echo "Erro: O arquivo .env não existia e foi criado a partir de .env.example." >&2
    echo "É necessário preencher AI_PROVIDER, AI_MODEL e a respectiva chave de API" >&2
    echo "(GEMINI_API_KEY, OPENROUTER_API_KEY ou GROQ_API_KEY) no arquivo .env antes de rodar a demo." >&2
    exit 1
  else
    echo "Erro: Nem o arquivo .env nem o arquivo .env.example foram encontrados em $ROOT_DIR." >&2
    exit 1
  fi
fi

# Parse seguro do .env sem usar 'source'
declare -A ENV_VARS
ENV_VARS=()

re_double='^"(.*)"[[:space:]]*(#.*)?$'
re_single="^'(.*)'[[:space:]]*(#.*)?$"
re_line='^([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$'

while IFS= read -r linha || [ -n "$linha" ]; do
  # Remove espaços no início e no fim
  linha="${linha#"${linha%%[![:space:]]*}"}"
  linha="${linha%"${linha##*[![:space:]]}"}"

  [ -z "$linha" ] && continue
  [ "${linha:0:1}" = "#" ] && continue

  if [[ "$linha" =~ $re_line ]]; then
    chave="${BASH_REMATCH[1]}"
    valor="${BASH_REMATCH[2]}"

    if [[ "$valor" =~ $re_double ]]; then
      valor="${BASH_REMATCH[1]}"
    elif [[ "$valor" =~ $re_single ]]; then
      valor="${BASH_REMATCH[1]}"
    else
      # Remove comentários inline em valores sem aspas
      valor="${valor%%#*}"
      valor="${valor#"${valor%%[![:space:]]*}"}"
      valor="${valor%"${valor##*[![:space:]]}"}"
    fi

    ENV_VARS["$chave"]="$valor"
  fi
done < "$ENV_FILE"

AI_PROVIDER="${ENV_VARS[AI_PROVIDER]:-}"
AI_MODEL="${ENV_VARS[AI_MODEL]:-}"

if [ -z "$AI_PROVIDER" ]; then
  echo "Erro: A variável AI_PROVIDER não está definida ou está vazia no .env." >&2
  echo "Defina AI_PROVIDER=GEMINI, AI_PROVIDER=OPENROUTER ou AI_PROVIDER=GROQ no .env e rode de novo." >&2
  exit 1
fi

if [ -z "$AI_MODEL" ]; then
  echo "Erro: A variável AI_MODEL não está definida ou está vazia no .env." >&2
  echo "Defina AI_MODEL (ex.: gemini-3.5-flash-lite) no .env e rode de novo." >&2
  exit 1
fi

case "$AI_PROVIDER" in
  GEMINI)
    if [ -z "${ENV_VARS[GEMINI_API_KEY]:-}" ]; then
      echo "Erro: GEMINI_API_KEY está vazia no .env para o provedor GEMINI." >&2
      echo "Preencha a variável GEMINI_API_KEY no arquivo .env e rode de novo." >&2
      exit 1
    fi
    ;;
  OPENROUTER)
    if [ -z "${ENV_VARS[OPENROUTER_API_KEY]:-}" ]; then
      echo "Erro: OPENROUTER_API_KEY está vazia no .env para o provedor OPENROUTER." >&2
      echo "Preencha a variável OPENROUTER_API_KEY no arquivo .env e rode de novo." >&2
      exit 1
    fi
    ;;
  GROQ)
    if [ -z "${ENV_VARS[GROQ_API_KEY]:-}" ]; then
      echo "Erro: GROQ_API_KEY está vazia no .env para o provedor GROQ." >&2
      echo "Preencha a variável GROQ_API_KEY no arquivo .env e rode de novo." >&2
      exit 1
    fi
    ;;
  *)
    echo "Erro: Valor inválido para AI_PROVIDER ('$AI_PROVIDER') no .env." >&2
    echo "Valores aceitos: GEMINI | OPENROUTER | GROQ. Corrija o .env e rode de novo." >&2
    exit 1
    ;;
esac

echo "Configuração do .env validada (Provedor: $AI_PROVIDER, Modelo: $AI_MODEL)."

# -----------------------------------------------------------------------------
# [4/9] Portas do host
# -----------------------------------------------------------------------------
echo "[4/9] Verificando disponibilidade das portas no host..."

# Mesma precedência do docker compose: variável exportada no shell vence o .env, que vence o padrão.
# Ex.: POSTGRES_HOST_PORT=5433 ./scripts/start-demo.sh
FRONTEND_HOST_PORT="${FRONTEND_HOST_PORT:-${ENV_VARS[FRONTEND_HOST_PORT]:-5173}}"
BACKEND_HOST_PORT="${BACKEND_HOST_PORT:-${ENV_VARS[BACKEND_HOST_PORT]:-8080}}"
LANA_HOST_PORT="${LANA_HOST_PORT:-${ENV_VARS[LANA_HOST_PORT]:-8000}}"
LANA_GRPC_HOST_PORT="${LANA_GRPC_HOST_PORT:-${ENV_VARS[LANA_GRPC_HOST_PORT]:-50051}}"
POSTGRES_HOST_PORT="${POSTGRES_HOST_PORT:-${ENV_VARS[POSTGRES_HOST_PORT]:-5432}}"
export FRONTEND_HOST_PORT BACKEND_HOST_PORT LANA_HOST_PORT LANA_GRPC_HOST_PORT POSTGRES_HOST_PORT

checar_porta() {
  local porta="$1"
  local var_env="$2"

  local em_uso
  em_uso=$(python3 -c "
import socket, sys
p = int(sys.argv[1])
for h in ['0.0.0.0', '127.0.0.1']:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind((h, p))
        s.close()
    except OSError:
        sys.exit(1)
sys.exit(0)
" "$porta" 2>/dev/null && echo "0" || echo "1")

  if [ "$em_uso" -eq 1 ]; then
    # Porta em uso: verificar se pertence a algum container DESTE compose
    local container_proprio=0
    local cids_compose=()
    while IFS= read -r cid; do
      [ -n "$cid" ] && cids_compose+=("$cid")
    done < <(docker compose ps -q 2>/dev/null || true)

    local cids_ocupantes=()
    while IFS= read -r cid; do
      [ -n "$cid" ] && cids_ocupantes+=("$cid")
    done < <(docker ps --filter "publish=$porta" -q 2>/dev/null || true)

    if [ "${#cids_compose[@]}" -gt 0 ] && [ "${#cids_ocupantes[@]}" -gt 0 ]; then
      local todos_proprios=1
      for occ in "${cids_ocupantes[@]}"; do
        local achou=0
        for own in "${cids_compose[@]}"; do
          if [[ "$own" == "$occ"* ]] || [[ "$occ" == "$own"* ]]; then
            achou=1
            break
          fi
        done
        if [ "$achou" -eq 0 ]; then
          todos_proprios=0
          break
        fi
      done
      if [ "$todos_proprios" -eq 1 ]; then
        container_proprio=1
      fi
    fi

    if [ "$container_proprio" -eq 0 ]; then
      local porta_sugerida=$((porta + 1))
      echo "Erro: A porta $porta já está em uso por outro processo ou container no host." >&2
      echo "Defina $var_env=$porta_sugerida no .env e rode de novo." >&2
      exit 1
    fi
  fi
}

checar_porta "$FRONTEND_HOST_PORT" "FRONTEND_HOST_PORT"
checar_porta "$BACKEND_HOST_PORT" "BACKEND_HOST_PORT"
checar_porta "$LANA_HOST_PORT" "LANA_HOST_PORT"
checar_porta "$LANA_GRPC_HOST_PORT" "LANA_GRPC_HOST_PORT"
checar_porta "$POSTGRES_HOST_PORT" "POSTGRES_HOST_PORT"

echo "Todas as portas estão disponíveis para uso."

# -----------------------------------------------------------------------------
# [5/9] Processamento da opção --reset
# -----------------------------------------------------------------------------
echo "[5/9] Processando opções de inicialização..."

if [ "$DO_RESET" -eq 1 ]; then
  echo ""
  read -r -p "Isso apaga o banco da demo. Continuar? [s/N] " resp_reset
  case "$resp_reset" in
    [sS]|[sS][iI][mM])
      echo "Limpando containers e volumes deste projeto compose..."
      docker compose down -v
      ;;
    *)
      echo "Operação de reset cancelada pelo usuário."
      exit 0
      ;;
  esac
fi

# -----------------------------------------------------------------------------
# [6/9] Subir containers
# -----------------------------------------------------------------------------
echo "[6/9] Subindo os containers (docker compose up -d --build)..."
echo "Aviso: a primeira execução pode demorar alguns minutos (build do backend Spring Boot, build da Lana com download do modelo de embedding, e npm ci do frontend)."

docker compose up -d --build

# -----------------------------------------------------------------------------
# [7/9] Esperar prontidão dos serviços
# -----------------------------------------------------------------------------
echo "[7/9] Aguardando prontidão dos serviços..."

BACKEND_URL="http://localhost:${BACKEND_HOST_PORT}"
LANA_URL="http://localhost:${LANA_HOST_PORT}"
FRONTEND_URL="http://localhost:${FRONTEND_HOST_PORT}"

# Espera Backend
echo "Aguardando backend em $BACKEND_URL..."
BACKEND_OK=0
for _ in $(seq 1 90); do
  code=$(curl --silent --output /dev/null --write-out "%{http_code}" -X POST "$BACKEND_URL/api/auth/login" \
    -H "Content-Type: application/json" -d '{}' || true)
  if [ "$code" = "400" ] || [ "$code" = "401" ]; then
    BACKEND_OK=1
    break
  fi
  sleep 2
done

if [ "$BACKEND_OK" -ne 1 ]; then
  echo "Erro: Backend não respondeu após 180s em $BACKEND_URL/api/auth/login." >&2
  echo "Verifique os logs do serviço com: docker compose logs --tail 50 backend" >&2
  exit 1
fi
echo "Backend pronto."

# Espera Lana
echo "Aguardando Lana em $LANA_URL/docs..."
LANA_OK=0
for _ in $(seq 1 60); do
  code=$(curl --silent --output /dev/null --write-out "%{http_code}" -X GET "$LANA_URL/docs" || true)
  if [ "$code" = "200" ]; then
    LANA_OK=1
    break
  fi
  sleep 2
done

if [ "$LANA_OK" -ne 1 ]; then
  echo "Erro: Lana não respondeu após 120s em $LANA_URL/docs." >&2
  echo "Verifique os logs do serviço com: docker compose logs --tail 50 lana" >&2
  exit 1
fi
echo "Lana pronta."

# Espera Frontend
echo "Aguardando frontend em $FRONTEND_URL/..."
FRONT_OK=0
for _ in $(seq 1 60); do
  code=$(curl --silent --output /dev/null --write-out "%{http_code}" -X GET "$FRONTEND_URL/" || true)
  if [ "$code" = "200" ]; then
    FRONT_OK=1
    break
  fi
  sleep 2
done

if [ "$FRONT_OK" -ne 1 ]; then
  echo "Erro: Frontend não respondeu após 120s em $FRONTEND_URL/." >&2
  echo "Verifique os logs do serviço com: docker compose logs --tail 50 frontend" >&2
  exit 1
fi
echo "Frontend pronto."

# -----------------------------------------------------------------------------
# [8/9] Dados e seeds
# -----------------------------------------------------------------------------
echo "[8/9] Verificando dados da base e aplicando seeds de demonstração..."

DB_USER="${ENV_VARS[DB_USERNAME]:-postgres}"
DB_NAME="camplana"

QTD_VENDAS=$(docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -t -A -c "SELECT count(*) FROM venda;" 2>/dev/null || echo "0")
QTD_VENDAS="${QTD_VENDAS//[!0-9]/}"
QTD_VENDAS="${QTD_VENDAS:-0}"

if [ "$QTD_VENDAS" -eq 0 ]; then
  echo "Tabela 'venda' vazia. Importando base completa jul-dez/2025..."
  "$ROOT_DIR/scripts/importar-dataset.sh" "$BACKEND_URL"
  echo "Importando intercorrências de RH..."
  "$ROOT_DIR/scripts/importar-intercorrencias.sh"
else
  echo "A tabela 'venda' já possui $QTD_VENDAS registros. Pulando importação do dataset e intercorrências."
fi

echo "Aplicando seed de campanhas (seed-demo.sql)..."
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" < "$ROOT_DIR/scripts/seed-demo.sql"

echo "Aplicando seed de solicitações de alteração (seed-demo-solicitacoes.sql)..."
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 --single-transaction -U "$DB_USER" -d "$DB_NAME" < "$ROOT_DIR/scripts/seed-demo-solicitacoes.sql"

echo "Seeds aplicados com sucesso."

# -----------------------------------------------------------------------------
# [9/9] Conferência final
# -----------------------------------------------------------------------------
echo "[9/9] Executando conferência final da aplicação..."

USUARIOS_CHECK=(gabriela sergio ana paulo)
SERGIO_TOKEN=""

for u in "${USUARIOS_CHECK[@]}"; do
  login_resp=$(curl --silent --show-error -X POST "$BACKEND_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${u}@camplana.com.br\",\"senha\":\"123456\"}")

  token=$(python3 -c "import sys, json; print(json.loads(sys.argv[1]).get('token', ''))" "$login_resp" 2>/dev/null || true)
  if [ -z "$token" ]; then
    echo "Erro: Falha na autenticação do usuário ${u}@camplana.com.br." >&2
    echo "Resposta recebida do backend: $login_resp" >&2
    exit 1
  fi

  if [ "$u" = "sergio" ]; then
    SERGIO_TOKEN="$token"
  fi
  echo " - Login de ${u}@camplana.com.br: OK"
done

# Consulta à fila com token do Sérgio
fila_resp=$(curl --silent --show-error -X GET "$BACKEND_URL/api/correcoes/fila" \
  -H "Authorization: Bearer $SERGIO_TOKEN")

qtd_fila=$(python3 -c "import sys, json; data = json.loads(sys.argv[1]); print(len(data) if isinstance(data, list) else -1)" "$fila_resp" 2>/dev/null || echo "-1")
if [ "$qtd_fila" -lt 0 ]; then
  echo "Erro: Falha ao consultar a fila de correções (/api/correcoes/fila) com o token do Sérgio." >&2
  echo "Resposta do backend: $fila_resp" >&2
  exit 1
fi
echo " - Fila de solicitações (/api/correcoes/fila): $qtd_fila pedidos pendentes para análise do Sérgio"

# Contagem de vendas e campanhas
total_vendas=$(docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -t -A -c "SELECT count(*) FROM venda;" 2>/dev/null || echo "0")
total_campanhas=$(docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -t -A -c "SELECT count(*) FROM campanha;" 2>/dev/null || echo "0")
echo " - Base operacional: ${total_vendas//[!0-9]/} vendas, ${total_campanhas//[!0-9]/} campanhas registradas"

# Teste da Lana ao vivo
if [ "$SEM_TESTE_LANA" -eq 0 ]; then
  echo " - Testando chamada ao vivo da Lana (agente IA)..."
  resp_tmp=$(mktemp)
  status_lana=$(curl --silent --show-error --write-out "%{http_code}" --output "$resp_tmp" \
    -X POST "$LANA_URL/agent/invoke" \
    -H "Content-Type: application/json" \
    -d '{"chat_id": "start-demo-check", "message": "Quantas lojas existem na base?"}' || true)
  corpo_lana=$(cat "$resp_tmp")
  rm -f "$resp_tmp"

  lana_respondeu=0
  if [ "$status_lana" = "200" ]; then
    texto_lana=$(python3 -c "import sys, json; print(json.loads(sys.argv[1]).get('response', ''))" "$corpo_lana" 2>/dev/null || true)
    if [ -n "$texto_lana" ]; then
      lana_respondeu=1
      echo " - Lana respondeu com sucesso: \"$texto_lana\""
    fi
  fi

  if [ "$lana_respondeu" -ne 1 ]; then
    echo "" >&2
    echo "============================================================" >&2
    echo "⚠️  ATENÇÃO: A Lana não respondeu como esperado (HTTP $status_lana)!" >&2
    echo "Resposta recebida: $corpo_lana" >&2
    echo "" >&2
    echo "Possíveis causas e como resolver:" >&2
    echo " 1. Limite de cota atingido (ex.: HTTP 429 Too Many Requests)." >&2
    echo " 2. Chave de API inválida ou expirada." >&2
    echo " O que fazer:" >&2
    echo " - No arquivo .env, altere AI_PROVIDER (ex.: GROQ ou OPENROUTER) e AI_MODEL," >&2
    echo "   ou configure provedores de reserva em AI_FALLBACKS." >&2
    echo " - Consulte os logs detalhados: docker compose logs --tail 50 lana" >&2
    echo " Nota: Os serviços permanecem ativos para navegação e demonstração." >&2
    echo "============================================================" >&2
    echo "" >&2
  fi
else
  echo " - Flag --sem-teste-lana informada: teste de chamada ao vivo da Lana ignorado."
fi

# -----------------------------------------------------------------------------
# Resumo final e Roteiro da Demonstração
# -----------------------------------------------------------------------------
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
if [ -z "$LOCAL_IP" ]; then
  LOCAL_IP="localhost"
fi

echo ""
echo "============================================================"
echo "    🎉 Ambiente Pronto para Apresentação da Sprint 3!"
echo "============================================================"
echo ""
echo "Endereços de acesso:"
echo " - Aplicação Frontend: http://localhost:${FRONTEND_HOST_PORT} (ou http://${LOCAL_IP}:${FRONTEND_HOST_PORT})"
echo " - Backend Spring Boot: http://localhost:${BACKEND_HOST_PORT}"
echo " - Swagger/Docs Lana:  http://localhost:${LANA_HOST_PORT}/docs"
echo " - PostgreSQL:         localhost:${POSTGRES_HOST_PORT}"
echo ""
echo "Usuários de teste (senha padrão para todos: 123456):"
echo " - gabriela@camplana.com.br (GERENTE - chat, campanhas, correções)"
echo " - sergio@camplana.com.br   (SUPERVISOR - aprovação de campanhas e fila de correções)"
echo " - silvia@camplana.com.br   (SUPERVISOR - aprovação e simulação)"
echo " - ana@camplana.com.br      (ADMIN - gestão de usuários em /admin)"
echo " - paulo@camplana.com.br    (AUDITOR - consulta da trilha de auditoria)"
echo ""
echo "Roteiro da Demonstração (Sprint 3):"
echo " 1. Gabriela pede no chat (login como gabriela@camplana.com.br):"
echo "    - Correção de loja: 'A MATRIC-38 foi transferida da loja 33 para a loja 8 em outubro de 2025; foi transferência a pedido da regional'"
echo "    - Intercorrência RH: 'A MATRIC-12 vai tirar férias de 01/12/2025 a 15/12/2025, férias programadas'"
echo "    - Revisa os dados nos cartões gerados pela Lana e clica em 'Confirmar'."
echo ""
echo " 2. Sérgio avalia os pedidos (login como sergio@camplana.com.br):"
echo "    - Acessa o menu 'Solicitações' (/solicitacoes) e vê os itens com a origem"
echo "      'aberta pela Lana a pedido de Gabriela'."
echo "    - Tenta reprovar sem justificativa para ver a validação 'Justificativa obrigatória para reprovar'."
echo "    - Reprova um pedido preenchendo justificativa e aprova o outro pedido."
echo ""
echo " 3. Gabriela confere o resultado:"
echo "    - Acessa 'Meus pedidos' (na tela Solicitações) e confere o status atualizado (Aprovada e Reprovada)."
echo "============================================================"
