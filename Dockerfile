###################################################################################
# Set the branch to build from the command line with --build-arg, for example:
# $ docker build --build-arg VALIDATOR_BRANCH=itn4 .
###################################################################################
ARG VALIDATOR_BRANCH="itn4"
ARG CLI_BRANCH="itn4"
ARG GUI_BRANCH="itn4"

## Network details
ARG APP_MONITOR="34.28.123.3"
ARG RPC_SERVER_URL="http://34.42.232.167:8000 "
ARG EXISTING_ARCHIVERS='[{"ip":"35.193.191.159","port":4000,"publicKey":"1c63734aedef5665d6cf02d3a79ae30aedcbd27eae3b76fff05d587a6ac62981"},{"ip":"34.73.94.45","port":4000,"publicKey":"11086314ccf8642906b99f09cf3ae9a13370c57106653cd28fc1a9eee2560b64"},{"ip":"34.19.93.147","port":4000,"publicKey":"b09a8792593682cbffbbf2fc3bd812d8143740197a5f435c77a38740397088ac"}]'
ARG NEXT_PUBLIC_RPC_URL="http://34.42.232.167:8000 "
ARG NEXT_EXPLORER_URL="http://35.238.111.77:6001"
ARG SHMEXT=9001
ARG SHMINT=10001
ARG DASHPORT=8080
ARG RUNDASHBOARD="y"
ARG INT_IP="auto"
ARG LOCALLANIP="auto"
ARG EXT_IP="auto"
ARG SERVERIP="auto"

## These should not be changed often or easily without thourough testing
## 6 Gigabytes of memory for the node process for the validator to deal with the large amount of data it has to be able to handle
ARG NODE_OPTIONS="--max-old-space-size=6144"
ARG minNodes=1280
ARG baselineNodes=1280
ARG nodesPerConsensusGroup=128
ARG maxNodes=1500

## Define what Docker Node version image to use for the build & final image
ARG NODE_VERSION=18.19.1


###################################################################################
### Build the Shardeum Validator image from https://github.com/shardeum/shardeum
###################################################################################
FROM node:${NODE_VERSION} AS validator

ARG VALIDATOR_BRANCH
ARG CLI_BRANCH
ARG GUI_BRANCH
ARG APP_MONITOR
ARG RPC_SERVER_URL
ARG EXISTING_ARCHIVERS
ARG NEXT_PUBLIC_RPC_URL
ARG NEXT_EXPLORER_URL
ARG SHMEXT
ARG SHMINT
ARG DASHPORT
ARG RUNDASHBOARD
ARG INT_IP
ARG EXT_IP
ARG LOCALLANIP
ARG SERVERIP
ARG NODE_OPTIONS

## Inherit the ARGs from the to level and expose them in the final image
ENV APP_MONITOR=$APP_MONITOR
ENV RPC_SERVER_URL=$RPC_SERVER_URL
ENV EXISTING_ARCHIVERS=$EXISTING_ARCHIVERS
ENV NEXT_PUBLIC_RPC_URL=$NEXT_PUBLIC_RPC_URL
ENV NEXT_EXPLORER_URL=$NEXT_EXPLORER_URL
ENV SHMEXT=$SHMEXT
ENV SHMINT=$SHMINT
ENV DASHPORT=$DASHPORT
ENV RUNDASHBOARD=$RUNDASHBOARD
ENV INT_IP=$INT_IP
ENV EXT_IP=$EXT_IP
ENV LOCALLANIP=$LOCALLANIP
ENV SERVERIP=$SERVERIP
ENV NODE_OPTIONS=$NODE_OPTIONS

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl logrotate iproute2 nano git openssl

## Create CLI and GUI target directories as root & set permissions
RUN mkdir -p /usr/src/app && chown -R node:node /usr/src/app && chmod 2775 -R /usr/src/app
RUN mkdir -p /home/node/app/cli && chown -R node:node /home/node/app && chmod 2775 -R /home/node/app
RUN mkdir -p /home/node/app/gui && chown -R node:node /home/node/app/gui && chmod 2775 -R /home/node/app/gui

## Install Rust for the validator build
USER node
WORKDIR /home/node
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN . /home/node/.cargo/env
ENV PATH="/home/node/.cargo/bin:${PATH}"
RUN rustup install 1.74.1 && rustup default 1.74.1
ENV NPM_CONFIG_loglevel=error

WORKDIR /usr/src/app
ENV VALIDATOR_BRANCH=${VALIDATOR_BRANCH}
RUN git clone https://github.com/shardeum/shardeum.git . && \
    git checkout ${VALIDATOR_BRANCH}
RUN npm ci
RUN npm run compile


###################################################################################
### Build the CLI image from https://github.com/shardeum/validator-cli
###################################################################################
FROM node:${NODE_VERSION} AS cli

ARG VALIDATOR_BRANCH
ARG CLI_BRANCH
ARG GUI_BRANCH
ARG APP_MONITOR
ARG RPC_SERVER_URL
ARG EXISTING_ARCHIVERS
ARG NEXT_PUBLIC_RPC_URL
ARG NEXT_EXPLORER_URL
ARG SHMEXT
ARG SHMINT
ARG DASHPORT
ARG RUNDASHBOARD
ARG INT_IP
ARG EXT_IP
ARG LOCALLANIP
ARG SERVERIP
ARG NODE_OPTIONS

## Inherit the ARGs from the to level and expose them in the final image
ENV APP_MONITOR=$APP_MONITOR
ENV RPC_SERVER_URL=$RPC_SERVER_URL
ENV EXISTING_ARCHIVERS=$EXISTING_ARCHIVERS
ENV NEXT_PUBLIC_RPC_URL=$NEXT_PUBLIC_RPC_URL
ENV NEXT_EXPLORER_URL=$NEXT_EXPLORER_URL
ENV SHMEXT=$SHMEXT
ENV SHMINT=$SHMINT
ENV DASHPORT=$DASHPORT
ENV RUNDASHBOARD=$RUNDASHBOARD
ENV INT_IP=$INT_IP
ENV EXT_IP=$EXT_IP
ENV LOCALLANIP=$LOCALLANIP
ENV SERVERIP=$SERVERIP
ENV NODE_OPTIONS=$NODE_OPTIONS
ENV NPM_CONFIG_loglevel=error

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl iproute2 git

## Create CLI and GUI target directories as root & set permissions
RUN mkdir -p /usr/src/app && chown -R node:node /usr/src/app && chmod 2775 -R /usr/src/app
RUN mkdir -p /home/node/app/cli && chown -R node:node /home/node/app && chmod 2775 -R /home/node/app
RUN mkdir -p /home/node/app/gui && chown -R node:node /home/node/app/gui && chmod 2775 -R /home/node/app/gui
USER node
WORKDIR /home/node/app
ENV CLI_BRANCH=${CLI_BRANCH}
RUN git clone https://github.com/shardeum/validator-cli.git cli && cd cli && \
    git checkout ${CLI_BRANCH}
WORKDIR /home/node/app/cli
RUN npm ci
RUN npm run compile


###################################################################################
### Build the GUI image from https://github.com/shardeum/validator-gui
###################################################################################
FROM node:${NODE_VERSION} AS gui

ARG VALIDATOR_BRANCH
ARG CLI_BRANCH
ARG GUI_BRANCH
ARG APP_MONITOR
ARG RPC_SERVER_URL
ARG EXISTING_ARCHIVERS
ARG NEXT_PUBLIC_RPC_URL
ARG NEXT_EXPLORER_URL
ARG SHMEXT
ARG SHMINT
ARG DASHPORT
ARG RUNDASHBOARD
ARG INT_IP
ARG EXT_IP
ARG LOCALLANIP
ARG SERVERIP
ARG NODE_OPTIONS

## Inherit the ARGs from the to level and expose them in the final image
ENV APP_MONITOR=$APP_MONITOR
ENV RPC_SERVER_URL=$RPC_SERVER_URL
ENV EXISTING_ARCHIVERS=$EXISTING_ARCHIVERS
ENV NEXT_PUBLIC_RPC_URL=$NEXT_PUBLIC_RPC_URL
ENV NEXT_EXPLORER_URL=$NEXT_EXPLORER_URL
ENV SHMEXT=$SHMEXT
ENV SHMINT=$SHMINT
ENV DASHPORT=$DASHPORT
ENV RUNDASHBOARD=$RUNDASHBOARD
ENV INT_IP=$INT_IP
ENV EXT_IP=$EXT_IP
ENV LOCALLANIP=$LOCALLANIP
ENV SERVERIP=$SERVERIP
ENV NODE_OPTIONS=$NODE_OPTIONS
ENV NPM_CONFIG_loglevel=error

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl iproute2 git

## Create CLI and GUI target directories as root & set permissions
RUN mkdir -p /usr/src/app && chown -R node:node /usr/src/app && chmod 2775 -R /usr/src/app
RUN mkdir -p /home/node/app/cli && chown -R node:node /home/node/app && chmod 2775 -R /home/node/app
RUN mkdir -p /home/node/app/gui && chown -R node:node /home/node/app/gui && chmod 2775 -R /home/node/app/gui
USER node
WORKDIR /home/node/app
ENV GUI_BRANCH=${GUI_BRANCH}
RUN git clone https://github.com/shardeum/validator-gui.git gui && cd gui && \
    git checkout ${GUI_BRANCH}
WORKDIR /home/node/app/gui
RUN npm ci
RUN npm run build


###################################################################################
### Build the final image
###################################################################################
# FROM node:${NODE_VERSION}-slim AS final
FROM node:${NODE_VERSION}-slim AS final

# Link this Dockerfile to the image in the GHCR
LABEL "org.opencontainers.image.source"="https://github.com/shardeum/shardeum-validator"
LABEL "org.opencontainers.image.description"="Shardeum Validator"

ARG APP_MONITOR
ARG RPC_SERVER_URL
ARG EXISTING_ARCHIVERS
ARG NEXT_PUBLIC_RPC_URL
ARG NEXT_EXPLORER_URL
ARG SHMEXT
ARG SHMINT
ARG DASHPORT
ARG RUNDASHBOARD
ARG INT_IP
ARG EXT_IP
ARG LOCALLANIP
ARG SERVERIP
ARG NODE_OPTIONS
ARG minNodes
ARG baselineNodes
ARG nodesPerConsensusGroup
ARG maxNodes

## Inherit the ARGs from the to level and expose them in the final image
ENV APP_MONITOR=$APP_MONITOR
ENV RPC_SERVER_URL=$RPC_SERVER_URL
ENV EXISTING_ARCHIVERS=$EXISTING_ARCHIVERS
ENV NEXT_PUBLIC_RPC_URL=$NEXT_PUBLIC_RPC_URL
ENV NEXT_EXPLORER_URL=$NEXT_EXPLORER_URL
ENV SHMEXT=$SHMEXT
ENV SHMINT=$SHMINT
ENV DASHPORT=$DASHPORT
ENV RUNDASHBOARD=$RUNDASHBOARD
ENV INT_IP=$INT_IP
ENV EXT_IP=$EXT_IP
ENV LOCALLANIP=$LOCALLANIP
ENV SERVERIP=$SERVERIP
ENV NODE_OPTIONS=$NODE_OPTIONS
ENV minNodes=$minNodes
ENV baselineNodes=$baselineNodes
ENV nodesPerConsensusGroup=$nodesPerConsensusGroup
ENV maxNodes=$maxNodes

RUN apt-get update
RUN apt-get install -y logrotate iproute2 nano git openssl curl procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p           /home/node/app /home/node/config /usr/src/app && \
    chown -R node:node /home/node/app /home/node/config /usr/src/app && \
    chmod 2777 -R      /home/node/app /home/node/config /usr/src/app

## Shardeum Validator 
# COPY --from=validator --chown=node:node /usr/src/app       /usr/src/app
COPY --from=validator --chown=node:node /usr/src/app/dist /usr/src/app/dist
COPY --from=validator --chown=node:node /usr/src/app/node_modules /usr/src/app/node_modules
COPY --from=validator --chown=node:node /usr/src/app/config.json /usr/src/app/config.json
COPY --from=validator --chown=node:node /usr/src/app/package.json /usr/src/app/package.json
COPY --from=validator --chown=node:node /usr/src/app/package-lock.json /usr/src/app/package-lock.json
### CLI
COPY --from=cli --chown=node:node    /home/node/app/cli /home/node/app/cli
## GUI
COPY --from=gui --chown=node:node    /home/node/app/gui /home/node/app/gui
## Misc scripts
COPY --chown=node:node                  entrypoint.sh      /home/node/app/
COPY --chown=node:node                  scripts/*.sh       /home/node/app/
COPY --chown=node:node                  scripts/*.js       /home/node/app/

## Map the GUIs certificates to the config directory, these will be broken links until the first time entry.sh is run & they'e auto-generated
RUN cd /home/node/app/gui && \
    ln -s /home/node/config/CA.cnf && \
    ln -s /home/node/config/CA_cert.pem && \
    ln -s /home/node/config/CA_cert.srl && \
    ln -s /home/node/config/CA_key.pem && \
    ln -s /home/node/config/selfsigned.cnf && \
    ln -s /home/node/config/selfsigned.csr && \
    ln -s /home/node/config/selfsigned.key && \
    ln -s /home/node/config/selfsigned_node.crt && \
    ln -s /home/node/config/selfsigned.crt

## Map the CLI's cli-secrets.json from the config directory
RUN cd /home/node/app/cli/build/ && \
    touch /home/node/config/cli-secrets.json && \
    chown node:node /home/node/config/cli-secrets.json && \
    ln -s /home/node/config/cli-secrets.json secrets.json

RUN cd /home/node/app/cli && npm link
RUN ln -s /usr/src/app /home/node/app/validator

## Install PM2 globally
RUN npm install -g pm2

RUN echo '/home/node/.pm2/logs/*.log /home/node/app/cli/build/logs/*.log {\n\
    daily\n\
    rotate 7\n\
    compress\n\
    delaycompress\n\
    missingok\n\
    notifempty\n\
    create 0640 user group\n\
    sharedscripts\n\
    postrotate\n\
    pm2 reloadLogs\n\
    endscript\n\
}"' > /etc/logrotate.d/pm2

## Link the env file to the various app directories so they're automatically loaded by the apps
RUN ln -s /home/node/env /home/node/app/cli/build/.env
RUN ln -s /home/node/env /home/node/app/cli/.env
RUN ln -s /home/node/env /home/node/app/gui/build/.env
RUN ln -s /home/node/env /home/node/app/gui/.env
RUN ln -s /home/node/env /usr/src/app/dist/src/.env
RUN ln -s /home/node/env /usr/src/app/.env

USER node
WORKDIR /home/node/app
CMD [ "./entrypoint.sh" ]
