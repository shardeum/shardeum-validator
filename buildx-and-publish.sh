#!/bin/bash

docker buildx build \
   --build-arg VALIDATOR_BRANCH=itn4 \
   --build-arg CLI_BRANCH=itn4 \
   --build-arg GUI_BRANCH=itn4 \
   --platform linux/amd64,linux/arm64 \
   -t github.com/shardeum/shardeum-validator \
   --push \
   .
