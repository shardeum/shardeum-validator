#!/bin/bash

docker buildx build \
   --build-arg VALIDATOR_BRANCH="itn1.15.4" \
   --build-arg CLI_BRANCH=main \
   --build-arg GUI_BRANCH=main \
   --network=host \
   --platform linux/amd64,linux/arm64 \
   -t github.com/shardeum/shardeum-validator \
   --push \
   .
