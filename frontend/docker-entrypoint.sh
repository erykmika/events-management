#!/bin/sh
set -e

# Debug: show incoming environment variables
echo "Runtime environment variables:"
echo "API_URL=${API_URL:-<not set>}"
echo "KEYCLOAK_BASE_URL=${KEYCLOAK_BASE_URL:-<not set>}"
echo "KEYCLOAK_REALM=${KEYCLOAK_REALM:-<not set>}"
echo "KEYCLOAK_CLIENT_ID=${KEYCLOAK_CLIENT_ID:-<not set>}"

# Fail fast if required variables are missing
: "${API_URL:?API_URL is not set}"
: "${KEYCLOAK_BASE_URL:?KEYCLOAK_BASE_URL is not set}"
: "${KEYCLOAK_REALM:?KEYCLOAK_REALM is not set}"
: "${KEYCLOAK_CLIENT_ID:?KEYCLOAK_CLIENT_ID is not set}"

# Create runtime config directory
mkdir -p /usr/share/nginx/html/config

# Write runtime config.json
cat <<EOF > /usr/share/nginx/html/config/config.json
{
  "api_url": "${API_URL}",
  "keycloak_base_url": "${KEYCLOAK_BASE_URL}",
  "keycloak_realm": "${KEYCLOAK_REALM}",
  "keycloak_client_id": "${KEYCLOAK_CLIENT_ID}"
}
EOF

echo "Runtime config generated:"
cat /usr/share/nginx/html/config/config.json

# Execute CMD from Dockerfile
exec "$@"
