# 🏠 Homelab Stack

Stack completo per homelab su Docker Desktop, pronto per conversione Terraform/LXD.

## Struttura

```
homelab/
├── docker-compose.yml          # Root: include tutti i domini
├── .env.example                # Template variabili d'ambiente
├── setup.sh                    # Script di inizializzazione
│
├── networking/
│   └── docker-compose.yml      # AdGuard DNS
│
├── monitoring/
│   ├── docker-compose.yml      # Grafana + Prometheus + Loki + Uptime Kuma
│   ├── prometheus.yml          # Config scrape Prometheus
│   ├── loki-config.yml         # Config Loki
│   └── promtail-config.yml     # Config Promtail (log collector)
│
├── automation/
│   └── docker-compose.yml      # n8n + Ansible Semaphore + NetBox + Home Assistant
│
├── ai/
│   └── docker-compose.yml      # Ollama (GPU) + AnythingLLM
│
└── security/
    ├── docker-compose.yml      # Authelia + Twingate
    └── authelia/
        ├── configuration.yml
        └── users_database.yml
```

## Prerequisiti

- Docker Desktop con WSL2
- NVIDIA Container Toolkit (per GPU)
- `openssl` disponibile nel terminale

## Primo avvio

```bash
# 1. Inizializza
chmod +x setup.sh
./setup.sh

# 2. Compila .env
cp .env.example .env
# edita .env con le tue credenziali

# 3. Avvia tutto
docker compose up -d

# Oppure per dominio singolo
docker compose -f monitoring/docker-compose.yml up -d
```

## Porte

| Servizio       | Porta  | URL                        |
|----------------|--------|----------------------------|
| AdGuard DNS    | 8080   | http://localhost:8080      |
| Grafana        | 3001   | http://localhost:3001      |
| Uptime Kuma    | 3002   | http://localhost:3002      |
| n8n            | 5678   | http://localhost:5678      |
| Semaphore      | 3003   | http://localhost:3003      |
| NetBox         | 8000   | http://localhost:8000      |
| Home Assistant | 8123   | http://localhost:8123      |
| AnythingLLM    | 3004   | http://localhost:3004      |
| Ollama API     | 11434  | http://localhost:11434     |
| Authelia       | 9091   | http://localhost:9091      |
| Prometheus     | 9090   | http://localhost:9090      |

## Note GPU

Ollama usa la prima GPU disponibile (`count: 1`).
Per usare una GPU specifica, modifica `ai/docker-compose.yml`:
```yaml
devices:
  - driver: nvidia
    device_ids: ['0']   # nvidia-smi per vedere gli ID
    capabilities: [gpu]
```

## Roadmap conversione Terraform → LXD/MicroCloud

Ogni dominio Docker corrisponderà a un modulo Terraform:
- `modules/networking/` → LXC AdGuard
- `modules/monitoring/` → LXC Grafana stack
- `modules/automation/` → LXC n8n, Semaphore, NetBox, HA
- `modules/ai/`         → LXC Ollama con GPU passthrough
- `modules/security/`   → LXC Authelia, Twingate
