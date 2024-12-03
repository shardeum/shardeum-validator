###################################################################################
# Set the branch to build from the command line with --build-arg, for example:
# $ docker build --build-arg VALIDATOR_BRANCH=itn-1.15.2 .
###################################################################################
ARG VALIDATOR_BRANCH="dev"
ARG CLI_BRANCH="dev"
ARG GUI_BRANCH="dev"

## This should not be changed often or easily without thourough testing
ARG NODE_VERSION=18.19.1

###################################################################################
### Build the Shardeum Validator image from https://github.com/shardeum/shardeum
###################################################################################
FROM node:${NODE_VERSION} AS validator
ARG VALIDATOR_BRANCH

# Install Rust build chain for modules
RUN apt-get update && apt-get install -y \
    build-essential \
    curl
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

RUN apt-get update
RUN apt-get install -y sudo logrotate iproute2

RUN mkdir -p           /home/node/app /home/node/config /usr/src/app && \
    chown -R node:node /home/node/app /home/node/config /usr/src/app && \
    chmod 2775 -R      /home/node/app /home/node/config /usr/src/app

COPY --from=validator --chown=node:node /usr/src/app /usr/src/app
COPY --from=cli --chown=node:node /home/node/app/cli /home/node/app/cli
COPY --from=gui --chown=node:node /home/node/app/gui /home/node/app/gui
COPY --chown=node:node entrypoint.sh /home/node/app/
COPY --chown=node:node scripts/operator-cli.sh scripts/set-password.sh scripts/shell.sh /home/node/config/

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

# Do the same for the validator secrets
RUN cd /usr/src/app/dist/src && \
    touch /home/node/config/validator-secrets.json && \
    chown node:node /home/node/config/validator-secrets.json && \
    ln -s /home/node/config/validator-secrets.json secrets.json

RUN cd /home/node/app/cli && npm link
RUN ln -s /usr/src/app /home/node/app/validator
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
RUN ln -s /home/node/config/env /home/node/app/cli/build/.env
RUN ln -s /home/node/config/env /home/node/app/gui/build/.env
RUN ln -s /home/node/config/env /usr/src/app/dist/src/.env
RUN ln -s /home/node/config/env /usr/src/app/.env

USER node
WORKDIR /home/node/app
CMD [ "./entrypoint.sh" ]
