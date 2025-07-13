#!/bin/bash

# Interrompe lo script se avviene un qualsiasi errore
set -e

REPO_DIR="/home/backend/culturallm-backend"
BACKEND_DIR="/home/backend/"
HASH_FILE="$BACKEND_DIR/.last_deploy_hash"
LOG_FILE="$BACKEND_DIR/git-deploy.log"
TEMP_LOG_FILE="$BACKEND_DIR/git-deploy.tmp.log"
PRE_DEPLOY_SCRIPT="$BACKEND_DIR/pre-deploy.sh"
TARGET_CONTAINER="culturallm-backend"

# Rimuove log temporaneo vecchio se esiste
rm -f "$TEMP_LOG_FILE"

merge_log() {
    cat "$TEMP_LOG_FILE" >> "$LOG_FILE"
}

# Funzione per gestire gli errori e salvare il log
on_error() {
    echo "[$(date)] ❌ Errore durante il deploy. Salvando log temporaneo..." >> "$LOG_FILE"
    merge_log
    rm -f "$TEMP_LOG_FILE"
}
trap on_error ERR

deploy_docker_compose() {
    if docker compose up -d --build; then
        echo "[$(date)] ✅ Deploy completato con successo."
    else
        echo "[$(date)] ❌ Errore durante docker compose up"
        exit 1
    fi
}

cd "$REPO_DIR" || exit 1

{
echo "============================="
echo "[$(date)] Inizio controllo aggiornamenti..."

# Aggiorna repo
git fetch origin develop
git reset --hard origin/develop

# Prendi l'hash attuale
CURRENT_HASH=$(git rev-parse HEAD)

# Esegui script pre-deploy se esiste
if [ -x "$PRE_DEPLOY_SCRIPT" ]; then
    echo "[$(date)] Eseguo pre-deploy script..."
    "$PRE_DEPLOY_SCRIPT"
else
    echo "[$(date)] ❌ Nessun pre-deploy script trovato."
fi

# Verifica se ci sono modifiche rispetto all'ultimo deploy
if [ -f "$HASH_FILE" ] && [ "$CURRENT_HASH" == "$(cat "$HASH_FILE")" ]; then
    echo "[$(date)] Nessun cambiamento, fine."

    # Se il container non è attivo...
    if ! docker ps --format '{{.Names}}' | grep -q "^$TARGET_CONTAINER$"; then
        echo "[$(date)] ⚠️ Container $TARGET_CONTAINER non attivo."

        # Verifica se Docker è attivo
        if ! systemctl is-active --quiet docker; then
            echo "[$(date)] 🔄 Docker non attivo. Avvio in corso..."
            sudo systemctl start docker
            echo "[$(date)] ✅ Docker avviato."
        else
            echo "[$(date)] ⚠️ Docker attivo ma container $TARGET_CONTAINER fermo."
            deploy_docker_compose
            merge_log
        fi
    else
        echo "[$(date)] ✅ Container $TARGET_CONTAINER già attivo."
    fi


    exit 0
fi

# Salva nuovo hash
echo "$CURRENT_HASH" > "$HASH_FILE"

echo "[$(date)] 🚨 TROVATE MODIFICHE..."
echo "[$(date)] Eseguo docker compose build & up..."

# Docker Compose Down
if docker compose down; then
    echo "[$(date)] ✅ docker compose down eseguito con successo"
else
    echo "[$(date)] ❌ Errore durante docker compose down"
    exit 1
fi

# Docker Compose Up
deploy_docker_compose

} > "$TEMP_LOG_FILE" 2>&1

# Se siamo arrivati qui, tutto è andato bene → non tenere il log
rm "$TEMP_LOG_FILE"
