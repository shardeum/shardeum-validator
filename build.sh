#!/bin/bash
docker build . --build-arg VALIDATOR_BRANCH=itn4 --build-arg CLI_BRANCH=itn4 --build-arg GUI_BRANCH=itn4 -t ghcr.io/shardeum/shardeum-validator-arm64:itn4-2
