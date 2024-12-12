#!/bin/bash
## add --no-cache once this is ready for release

docker build . --build-arg VALIDATOR_BRANCH=itn4 --build-arg CLI_BRANCH=itn4 --build-arg GUI_BRANCH=itn4 -t ghcr.io/shardeum/shardeum-validator:itn4-1
