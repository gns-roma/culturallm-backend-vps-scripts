HEADER="[pre-deploy.sh]"
BACKEND_DIR="/home/backend/"

echo "$HEADER copio il file compose dentro culturallm-backend/"
if cp "$BACKEND_DIR"docker-compose-backup.yaml "$BACKEND_DIR"culturallm-backend/; then
    echo "$HEADER copia del file avvenuta con successo."
else
    echo "$HEADER errore durante la copia del file."
fi

echo "$HEADER rimuovo il vecchio file compose da dentro culturallm-backend/"
if rm "$BACKEND_DIR"culturallm-backend/docker-compose.yaml; then
    echo "$HEADER rimozione avvenuta con successo."
else 
    echo "$HEADER errore durante la rimozione del file."
    exit 1
fi

echo "$HEADER rinomino il file con il giusto nome"
if mv "$BACKEND_DIR"culturallm-backend/docker-compose-backup.yaml "$BACKEND_DIR"culturallm-backend/docker-compose.yaml; then
    echo "$HEADER rinominazione del file avvenuta con successo."
else 
    echo "$HEADER errore durante la rinominazione del file."
    exit 1
fi
