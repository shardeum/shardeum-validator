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

IMAGE_NAME="shardeum/shardeum-validator-${ARCH_TAG}"
IMAGE_REF="ghcr.io/${IMAGE_NAME}:${TAG}"

# Ensure the image exists locally
if ! docker image inspect "$IMAGE_REF" > /dev/null 2>&1; then
    echo "Image $IMAGE_REF not found locally. Please pull or build it first. Exiting."
    exit 1
fi

# Get the image digest from local metadata
IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_REF" | cut -d'@' -f2)

if [ -z "$IMAGE_DIGEST" ]; then
    echo "Failed to retrieve image digest. Exiting."
    exit 1
fi

echo "Using image: $IMAGE_REF"
echo "Image digest: $IMAGE_DIGEST"

# Stop and remove any previous instance
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
    -e IMAGE_DIGEST="$IMAGE_DIGEST" \
    -e IMAGE_NAME="$IMAGE_NAME" \
    --restart=always \
    --detach \
    "$IMAGE_REF"
