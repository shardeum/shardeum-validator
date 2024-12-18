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

# Build and tag the image
docker build . \
    --push \
    --no-cache \
    --build-arg VALIDATOR_BRANCH=itn4 \
    --build-arg CLI_BRANCH=itn4 \
    --build-arg GUI_BRANCH=itn4 \
    -t ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}

echo "Build complete: ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}"
