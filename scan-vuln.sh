#!/bin/bash

if [ -z "$1" ]; then
    echo "No tag provided. Exiting."
    exit 1
fi
TAG=$1

ARCH=$(uname -m)
if [ "$ARCH" == "aarch64" ]; then
    ARCH_TAG="arm64"
elif [ "$ARCH" == "arm64" ]; then
    ARCH_TAG="arm64"
elif [ "$ARCH" == "x86_64" ]; then
    ARCH_TAG="amd64"
else
    echo "Unsupported architecture: $ARCH. Exiting."
    exit 1
fi

trivy image ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG} --pkg-types os --ignore-unfixed --severity HIGH,CRITICAL --scanners vuln --timeout 60m0s --format table --output trivy-high-and-critical.txt

