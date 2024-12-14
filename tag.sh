#!/bin/bash

TAG=$1

if [ -z "$TAG" ]; then
    echo "No tag provided. Exiting."
    exit 1
fi

echo "Pulling images"

docker pull ghcr.io/shardeum/shardeum-validator-arm64:$TAG
docker pull ghcr.io/shardeum/shardeum-validator-amd64:$TAG

echo "Tagging latest"

docker tag ghcr.io/shardeum/shardeum-validator-arm64:$TAG ghcr.io/shardeum/shardeum-validator-arm64:latest
docker tag ghcr.io/shardeum/shardeum-validator-amd64:$TAG ghcr.io/shardeum/shardeum-validator-amd64:latest

echo "Pushing latest"

docker push ghcr.io/shardeum/shardeum-validator-arm64:latest
docker push ghcr.io/shardeum/shardeum-validator-amd64:latest

echo "Creating $TAG manifest"

docker manifest create --amend ghcr.io/shardeum/shardeum-validator:$TAG ghcr.io/shardeum/shardeum-validator-arm64:$TAG ghcr.io/shardeum/shardeum-validator-amd64:$TAG
docker manifest push ghcr.io/shardeum/shardeum-validator:$TAG

echo "Creating :latest manifest"

docker manifest create --amend ghcr.io/shardeum/shardeum-validator:latest ghcr.io/shardeum/shardeum-validator-arm64:latest ghcr.io/shardeum/shardeum-validator-amd64:latest
docker manifest push ghcr.io/shardeum/shardeum-validator:latest

echo "Done"
