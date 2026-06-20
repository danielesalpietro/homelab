#!/bin/bash
# ============================================================
#  setup.sh — Inizializzazione stack Homelab
#  Esegui una volta prima di docker compose up
# ============================================================

set -e

echo "🏠 Homelab Stack — Setup iniziale"
echo "=================================="

# 1. Crea il file .env se non esiste
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✅ .env creato da .env.example — COMPILALO prima di continuare!"
  echo "   Genera i secret con: openssl rand -base64 32"
  exit 1
fi

# 2. Crea la rete Docker condivisa
echo ""
echo "📡 Creazione rete homelab_net..."
docker network create \
  --driver bridge \
  --subnet 172.20.0.0/16 \
  homelab_net 2>/dev/null || echo "   (rete già esistente, ok)"

# 3. Crea i volumi
echo ""
echo "💾 Creazione volumi..."
volumes=(
  adguard_data adguard_conf
  prometheus_data grafana_data loki_data uptime_kuma_data
  n8n_data semaphore_data netbox_data netbox_postgres netbox_redis
  ollama_data anythingllm_data
  authelia_data
  homeassistant_data
)
for vol in "${volumes[@]}"; do
  docker volume create "$vol" 2>/dev/null || true
  echo "   ✅ $vol"
done

# 4. Pull modello Ollama base
echo ""
echo "🤖 Pull modello Ollama (llama3.2)..."
echo "   (puoi saltare con Ctrl+C e farlo dopo)"
docker run --rm --gpus all \
  -v ollama_data:/root/.ollama \
  ollama/ollama:latest pull llama3.2 || \
  echo "   ⚠️  GPU non disponibile, il pull avverrà al primo avvio"

# 5. Genera hash password Authelia
echo ""
echo "🔐 Per generare l'hash della password Authelia:"
echo "   docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'tuapassword'"

echo ""
echo "✅ Setup completato!"
echo ""
echo "Prossimi passi:"
echo "  1. Compila il file .env con le tue password e token"
echo "  2. Aggiorna security/authelia/users_database.yml con il tuo hash"
echo "  3. docker compose up -d"
echo ""
echo "Porte principali:"
echo "  AdGuard DNS    → http://localhost:8080"
echo "  Grafana        → http://localhost:3001"
echo "  Uptime Kuma    → http://localhost:3002"
echo "  n8n            → http://localhost:5678"
echo "  Semaphore      → http://localhost:3003"
echo "  NetBox         → http://localhost:8000"
echo "  Home Assistant → http://localhost:8123"
echo "  AnythingLLM    → http://localhost:3004"
echo "  Ollama API     → http://localhost:11434"
echo "  Authelia       → http://localhost:9091"
echo "  Prometheus     → http://localhost:9090"
