#!/bin/sh
set -e

# Debug: show incoming environment variables
echo "Runtime environment variables:"
echo "API_URL=${API_URL:-<not set>}"
echo "COGNITO_USER_POOL_ID=${COGNITO_USER_POOL_ID:-<not set>}"
echo "COGNITO_APP_CLIENT_ID=${COGNITO_APP_CLIENT_ID:-<not set>}"

# Fail fast if required variables are missing
: "${API_URL:?API_URL is not set}"
: "${COGNITO_USER_POOL_ID:?COGNITO_USER_POOL_ID is not set}"
: "${COGNITO_APP_CLIENT_ID:?COGNITO_APP_CLIENT_ID is not set}"

# Create runtime config directory
mkdir -p /usr/share/nginx/html/config

# Write runtime config.json
cat <<EOF > /usr/share/nginx/html/config/config.json
{
  "api_url": "${API_URL}",
  "aws_project_region": "${AWS_REGION:-us-east-1}",
  "aws_cognito_region": "${AWS_REGION:-us-east-1}",
  "aws_user_pools_id": "${COGNITO_USER_POOL_ID}",
  "aws_user_pools_web_client_id": "${COGNITO_APP_CLIENT_ID}"
}
EOF

echo "Runtime config generated:"
cat /usr/share/nginx/html/config/config.json

# Execute CMD from Dockerfile
exec "$@"
