HEADER="[import-cert.sh]"

echo "importing certificates..."

KEY_PATH="/etc/letsencrypt/live/test-api.culturallm.it/privkey.pem"
CERT_PATH="/etc/letsencrypt/live/test-api.culturallm.it/fullchain.pem"

echo "$HEADER importing key"
cp "$KEY_PATH" .

echo "$HEADER importing certificate"
cp "$CERT_PATH" .
