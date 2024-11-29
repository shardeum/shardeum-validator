#!/bin/bash
docker run \
    --name shardeum-validator \
    -p 8080:8080 \
    -p 9001:9001 \
    -p 10001:10001 \
    -v $(pwd)/shardeum:/home/node/config \
    --restart=always \
    --detach \
    shardeum-validator
