#!/bin/bash
## add --no-cache once this is ready for release

docker build . --build-arg VALIDATOR_BRANCH=1.15.3 --build-arg CLI_BRANCH=dev --build-arg GUI_BRANCH=dev -t shardeum-validator 
