#!/bin/bash
set -e

# Create configuration directory if it does not already exist
if [ ! -d "${FOUNDRY_VTT_DATA_PATH}/Config" ]; then
    mkdir -p "${FOUNDRY_VTT_DATA_PATH}/Config"
fi

# Create options file if it doesn't already exist
if [ ! -f "${FOUNDRY_VTT_DATA_PATH}/Config/options.json" ]; then
    cp "${HOME}/options.json" "${FOUNDRY_VTT_DATA_PATH}/Config"
fi

# Force set password passed from docker-compose or AWS
# if [ -f "${FOUNDRY_VTT_DATA_PATH}/Config/admin.txt" ]; then
#     rm "${FOUNDRY_VTT_DATA_PATH}/Config/admin.txt"
# fi

export FOUNDRY_HOSTNAME=$FOUNDRY_HOSTNAME
if [ -z ${FOUNDRY_HOSTNAME+x} ]; then
    FOUNDRY_HOSTNAME=localhost
fi

export FOUNDRY_AWS_CONFIG=""
export ADMIN_PASSWORD=$ADMIN_PASSWORD
if [[ $AWS_REGION || $AWS_ACCESS_KEY_ID || $AWS_SECRET_ACCESS_KEY || $AWS_DEFAULT_REGION ]]; then
    mkdir -p ~/.aws/
    echo "[default]" > "${HOME}/.aws/config"
    echo "region=${AWS_REGION}" >> "${HOME}/.aws/config"
    # OPTIONS=$(jq '.' "${FOUNDRY_VTT_DATA_PATH}/Config/options.json")
    # OPTIONS=$(echo $OPTIONS | jq \
    #     --arg AWS_CONFIG "$HOME/.aws/config" \
    #     --arg AWS_REGION "$AWS_REGION" \
    #     --arg AWS_ACCESS_KEY_ID "$AWS_ACCESS_KEY_ID" \
    #     --arg AWS_SECRET_ACCESS_KEY "$AWS_SECRET_ACCESS_KEY" \
    #     -M '. + {
    #         accessKeyId: $AWS_ACCESS_KEY_ID,
    #         awsConfig: $AWS_CONFIG,
    #         region: $AWS_REGION,
    #         secretAccessKey: $AWS_SECRET_ACCESS_KEY
    #     }')
    # echo -E "${OPTIONS}" > "${FOUNDRY_VTT_DATA_PATH}/Config/options.json"
    aws ssm get-parameters --names "/app/${PROJECT}/${ENVIRONMENT}/TLS/cert" --with-decryption --query "Parameters[*].Value" --output text | base64 -d > "${FOUNDRY_VTT_DATA_PATH}/Config/cert.pem"
    aws ssm get-parameters --names "/app/${PROJECT}/${ENVIRONMENT}/TLS/privkey" --with-decryption --query "Parameters[*].Value" --output text | base64 -d > "${FOUNDRY_VTT_DATA_PATH}/Config/privkey.pem"
    aws ssm get-parameters --names "/app/${PROJECT}/${ENVIRONMENT}/license" --with-decryption --query "Parameters[*].Value" --output text | base64 -d > "${FOUNDRY_VTT_DATA_PATH}/Config/license.json"
    # ADMIN_PASSWORD=$(aws ssm get-parameters --names "/app/${PROJECT}/${ENVIRONMENT}/admin/password" --with-decryption --query "Parameters[*].Value" --output text)
elif [[ $SSL_CERT_BASE64 ]] || [[ $SSL_KEY_BASE64 ]]; then
    echo "${SSL_KEY_BASE64}" | base64 -d > "${FOUNDRY_VTT_DATA_PATH}/Config/privkey.pem"
    echo "${SSL_CERT_BASE64}" | base64 -d > "${FOUNDRY_VTT_DATA_PATH}/Config/cert.pem"
elif [[ $FOUNDRY_HOSTNAME ]]; then
    openssl req -x509 -nodes -newkey rsa:4096 -keyout "${FOUNDRY_VTT_DATA_PATH}/Config/privkey.pem" -out "${FOUNDRY_VTT_DATA_PATH}/Config/cert.pem" -sha256 -days 365 -subj "/CN=${VTT_FOUNDRY_HOSTNAME}" &> /dev/null
else
    openssl req -x509 -nodes -newkey rsa:4096 -keyout "${FOUNDRY_VTT_DATA_PATH}/Config/privkey.pem" -out "${FOUNDRY_VTT_DATA_PATH}/Config/cert.pem" -sha256 -days 365 -subj "/CN=localhost" &> /dev/null
fi

# Begin setting all of my presets
OPTIONS=$(jq '.' "${FOUNDRY_VTT_DATA_PATH}/Config/options.json")
OPTIONS=$(echo $OPTIONS | jq \
    --arg FOUNDRY_HOSTNAME "$FOUNDRY_HOSTNAME" \
    --arg FOUNDRY_VTT_DATA_PATH "$FOUNDRY_VTT_DATA_PATH" \
    --arg PORT "$PORT" \
    --arg SSLCERT "cert.pem" \
    --arg SSLKEY "privkey.pem" \
    -M '. + {
        dataPath: $FOUNDRY_VTT_DATA_PATH,
        hostname: $FOUNDRY_HOSTNAME,
        isSSL: true,
        proxySSL: true,
        upnp: true,
        sslCert: $SSLCERT,
        sslKey: $SSLKEY
    }')

echo -E "${OPTIONS}" > "${FOUNDRY_VTT_DATA_PATH}/Config/options.json"

# Run FoundryVTT
/usr/local/bin/node resources/app/main.js --dataPath="$FOUNDRY_VTT_DATA_PATH"
