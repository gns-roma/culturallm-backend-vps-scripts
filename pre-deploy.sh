#!/bin/bash

HEADER="[pre-deploy.sh]"
BACKEND_DIR="/home/backend/"

# Copia il file compose
if ! cp "$BACKEND_DIR"docker-compose-backup.yaml "$BACKEND_DIR"culturallm-backend/; then
    echo "$HEADER Errore durante la copia del file docker-compose-backup.yaml." >&2
    exit 1
fi

# Rimuove il vecchio file compose
if ! rm "$BACKEND_DIR"culturallm-backend/docker-compose.yaml; then
    echo "$HEADER Errore durante la rimozione del vecchio docker-compose.yaml." >&2
    exit 1
fi

# Rinomina il file in modo corretto
if ! mv "$BACKEND_DIR"culturallm-backend/docker-compose-backup.yaml "$BACKEND_DIR"culturallm-backend/docker-compose.yaml; then
    echo "$HEADER Errore durante la rinominazione del file in docker-compose.yaml." >&2
    exit 1
fi
