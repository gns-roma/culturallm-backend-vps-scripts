#!/bin/bash

# interrompe lo script se avviene un qualsiasi errore
set -e

REPO_DIR="/home/backend/culturallm-backend"
BACKEND_DIR="/home/backend/"
HASH_FILE="$BACKEND_DIR/.last_deploy_hash"
LOG_FILE="$BACKEND_DIR/git-deploy.log"
PRE_DEPLOY_SCRIPT="$BACKEND_DIR/pre-deploy.sh"
COMPOSE_FILE="$REPO_DIR/docker-compose.yml"

cd "$REPO_DIR" || exit 1

# Logging
echo "=============================" >> "$LOG_FILE"
echo "[$(date)] Inizio controllo aggiornamenti..." >> "$LOG_FILE"

# Aggiorna repo
git fetch origin main >> "$LOG_FILE" 2>&1
git reset --hard origin/main >> "$LOG_FILE" 2>&1

# Prendi l'hash attuale
CURRENT_HASH=$(git rev-parse HEAD)

# Esegui script pre-deploy se esiste
if [ -x "$PRE_DEPLOY_SCRIPT" ]; then
    echo "[$(date)] Eseguo pre-deploy script..." >> "$LOG_FILE"
    "$PRE_DEPLOY_SCRIPT" >> "$LOG_FILE" 2>&1
else
    echo "[$(date)] Nessun pre-deploy script trovato." >> "$LOG_FILE"
fi


# Verifica se ci sono modifiche rispetto all'ultimo deploy
if [ -f "$HASH_FILE" ] && [ "$CURRENT_HASH" == "$(cat "$HASH_FILE")" ]; then
    echo "[$(date)] Nessun cambiamento, fine." >> "$LOG_FILE"
    exit 0
fi

# Salva nuovo hash
echo "$CURRENT_HASH" > "$HASH_FILE"


# Esegui docker-compose
echo "[$(date)] Eseguo docker-compose build & up..." >> "$LOG_FILE"
docker compose -f "$COMPOSE_FILE" down >> "$LOG_FILE" 2>&1
docker compose -f "$COMPOSE_FILE" up -d --build >> "$LOG_FILE" 2>&1

echo "[$(date)] ✅ Deploy completato con successo." >> "$LOG_FILE"
