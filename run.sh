#!/bin/bash
docker run \
    --name shardeum-validator \
    -p 8080:8080/tcp \
    -p 9001:9001/tcp \
    -p 10001:10001/tcp \
    -v $(pwd)/shardeum:/home/node/config \
    --restart=always \
    --detach \
    shardeum-validator
