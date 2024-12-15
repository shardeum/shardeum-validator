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
elif [ "$ARCH" == "x86_64" ]; then
    ARCH_TAG="amd64"
else
    echo "Unsupported architecture: $ARCH. Exiting."
    exit 1
fi

docker run \
    --name shardeum-validator \
    -p 8080:8080/tcp \
    -p 9001:9001/tcp \
    -p 10001:10001/tcp \
    -v $(pwd)/shardeum:/home/node/config \
    --restart=always \
    --detach \
    ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}"
