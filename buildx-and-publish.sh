#!/bin/bash
docker buildx use multiarch
docker buildx build \
   --build-arg VALIDATOR_BRANCH=it4-1.16.1 \
   --build-arg CLI_BRANCH=itn4 \
   --build-arg GUI_BRANCH=itn4 \
   --platform linux/amd64,linux/arm64 \
   -t ghcr.io/shardeum/shardeum-validator:itn4-1 \
   --push \
   .
