#!/bin/bash
if [ -z "$1" ]; then
    echo "No tag provided. Exiting."
    exit 1
fi
TAG=$1

# Determine the architecture
ARCH=$(uname -m)
if [ "$ARCH" == "aarch64" ]; then
    ARCH_TAG="arm64"
elif [ "$ARCH" == "arm64" ]; then
    ARCH_TAG="arm64"
elif [ "$ARCH" == "x86_64" ]; then
    ARCH_TAG="amd64"
else
    echo "Unsupported architecture: $ARCH. Exiting."
    exit 1
fi

## Stop and remove any previous instance of the validator if it exists
if docker ps --filter "name=shardeum-validator" --format "{{.Names}}" | grep -q "^shardeum-validator$"; then
    echo "Stopping and removing previous instance of shardeum-validator"
    docker stop shardeum-validator 2>/dev/null
    docker rm shardeum-validator 2>/dev/null
fi

docker run \
    --name shardeum-validator \
    -p 8080:8080/tcp \
    -p 9001:9001/tcp \
    -p 10001:10001/tcp \
    -v $(pwd)/shardeum:/home/node/config \
    --restart=always \
    --detach \
    ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}
