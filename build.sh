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
    --no-cache \
    --build-arg VALIDATOR_BRANCH=it4-1.16.1 \
    --build-arg CLI_BRANCH=main \
    --build-arg GUI_BRANCH=main \
    -t ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}

echo "Build complete: ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}"
