FROM node:20

ENV HOME=/home/node \
    USER=node \
    FOUNDRY_VTT_DATA_PATH=/opt/foundry-data

COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY foundryvtt /home/node/foundryvtt

RUN chown node:0 ${HOME} && \
    apt-get update -qy > /dev/null  && \
    apt-get install -yq unzip openssl curl jq > /dev/null && \
    apt-get clean all > /dev/null  && \
    curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    curl -sL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    unzip -q awscliv2.zip && \
    ./aws/install > /dev/null && \
    dpkg -i session-manager-plugin.deb && \
    rm awscliv2.zip session-manager-plugin.deb && \
    mkdir -p ${FOUNDRY_VTT_DATA_PATH}/Config && \
    chown -R node:0 ${FOUNDRY_VTT_DATA_PATH} && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

COPY --chown=1000 options.json ${HOME}/options.json

USER 1000
WORKDIR ${HOME}/foundryvtt

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=1m --retries=5 \
   CMD curl -fsk https://localhost:30000/ || exit 1

