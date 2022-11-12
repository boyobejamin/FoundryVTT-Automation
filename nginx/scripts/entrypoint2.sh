#!/bin/bash
set -e

# Install SSL Certificates
if [[ $SSL_CERT_BASE64 ]] || [[ $SSL_KEY_BASE64 ]]; then
    echo "${SSL_KEY_BASE64}" | base64 -d > /etc/nginx/privkey.pem
    echo "${SSL_CERT_BASE64}" | base64 -d > /etc/nginx/cert.pem
else
    openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/nginx/privkey.pem -out /etc/nginx/cert.pem -sha256 -days 365 -subj "/CN=localhost" &> /dev/null
fi

exec "$@"
