###################################################################################
# Set the branch to build from the command line with --build-arg, for example:
# $ docker build --build-arg VALIDATOR_BRANCH=itn-1.15.2 .
###################################################################################
ARG VALIDATOR_BRANCH="1.15.3"
ARG CLI_BRANCH="main"
ARG GUI_BRANCH="dev"

## Network details
ARG APP_MONITOR="54.185.250.216"
ARG RPC_SERVER_URL="https://atomium.shardeum.org"
ARG EXISTING_ARCHIVERS="[{\"ip\":\"34.68.218.222\",\"port\":4000,\"publicKey\":\"64a3833499130406550729ab20f6bec351d04ec9be3e5f0144d54f01d4d18c45\"},{\"ip\":\"34.174.86.241\",\"port\":4000,\"publicKey\":\"9b4ba46439ea6cafc6b20d971ab0ef0f21b415c27482652efac96fd61a76d73c\"},{\"ip\":\"34.48.51.73\",\"port\":4000,\"publicKey\":\"ea72ef63e27cb960bfe02f17d40e74b5c28437af1d0df83dd21ba2084596789f\"}]"
ARG NEXT_PUBLIC_RPC_URL="https://atomium.shardeum.org"
ARG NEXT_EXPLORER_URL="https://explorer-atomium.shardeum.org"
ARG SHMEXT="9001"
ARG SHMINT="10001"
ARG DASHPORT="8080"
ARG RUNDASHBOARD="y"
ARG INT_IP="127.0.0.1"
ARG LOCALLANIP="127.0.0.1"
ARG EXT_IP="auto"
ARG SERVERIP="auto"


## This should not be changed often or easily without thourough testing
ARG NODE_VERSION=18.19.1

###################################################################################
### Build the Shardeum Validator image from https://github.com/shardeum/shardeum
###################################################################################
FROM node:${NODE_VERSION} AS validator
ARG VALIDATOR_BRANCH
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

# Install Rust build chain for modules
RUN apt-get update && apt-get install -y \
    build-essential curl
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN . $HOME/.cargo/env
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup install 1.74.1 && rustup default 1.74.1


WORKDIR /usr/src/app
#ENV NODE_ENV=production
ENV VALIDATOR_BRANCH=${VALIDATOR_BRANCH}
RUN git clone https://github.com/shardeum/shardeum.git . && \
    git switch ${VALIDATOR_BRANCH} && \
    npm install && \
    npm run compile


###################################################################################
### Build the CLI image from https://github.com/shardeum/validator-cli
###################################################################################
FROM node:${NODE_VERSION} AS cli
ARG CLI_BRANCH
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

RUN mkdir -p /home/node/app/cli && chown -R node:node /home/node/app && chmod 2775 -R /home/node/app
#RUN npm install typescript -g
USER node
WORKDIR /home/node/app
#ENV NODE_ENV=production
ENV CLI_BRANCH=${CLI_BRANCH}
RUN git clone https://github.com/shardeum/validator-cli.git cli && cd cli && \
    git switch ${CLI_BRANCH} && \
    npm install && \
    npm run compile


###################################################################################
### Build the GUI image from https://github.com/shardeum/validator-gui
###################################################################################
FROM node:${NODE_VERSION} AS gui
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

RUN mkdir -p /home/node/app/gui && chown -R node:node /home/node/app/gui && chmod 2775 -R /home/node/app/gui

USER node
WORKDIR /home/node/app
#ENV NODE_ENV=production
ENV GUI_BRANCH=${GUI_BRANCH}
RUN git clone https://github.com/shardeum/validator-gui.git gui && cd gui && \
    git switch ${GUI_BRANCH} && \
    npm install && \
    npm run build


###################################################################################
### Build the final image
###################################################################################
FROM node:${NODE_VERSION} AS final

# Link this Dockerfile to the image in the GHCR
LABEL "org.opencontainers.image.source"="https://github.com/shardeum/shardeum-validator"

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

RUN apt-get update
RUN apt-get install -y sudo logrotate iproute2 nano

RUN mkdir -p           /home/node/app /home/node/config /usr/src/app && \
    chown -R node:node /home/node/app /home/node/config /usr/src/app && \
    chmod 2775 -R      /home/node/app /home/node/config /usr/src/app

COPY --from=validator --chown=node:node /usr/src/app       /usr/src/app
COPY --from=cli --chown=node:node       /home/node/app/cli /home/node/app/cli
COPY --from=gui --chown=node:node       /home/node/app/gui /home/node/app/gui
COPY --chown=node:node                  entrypoint.sh      /home/node/app/
COPY --chown=node:node                  scripts/*.sh       /home/node/config/
COPY --chown=node:node                  scripts/*.js       /home/node/

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
