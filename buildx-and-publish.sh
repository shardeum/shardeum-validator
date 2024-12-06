#!/bin/bash

docker buildx build \
   --build-arg VALIDATOR_BRANCH="1.15.3" \
   --build-arg CLI_BRANCH=main \
   --build-arg GUI_BRANCH=dev \
   --platform linux/amd64,linux/arm64 \
   -t github.com/shardeum/shardeum-validator \
   .

#   --push \