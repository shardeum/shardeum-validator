#!/bin/bash
docker build . --no-cache --build-arg VALIDATOR_BRANCH=dev --build-arg CLI_BRANCH=dev --build-arg GUI_BRANCH=dev -t shardeum-validator 
