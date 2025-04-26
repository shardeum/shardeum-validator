#!/bin/bash

set -e

# Check if network name, tag, arch_tag, and registry are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "Usage: $0 <network_name> <tag> <arch_tag> <registry>"
  echo "Example: $0 testnet v1.0.0 amd64 ghcr.io"
  exit 1
fi

NETWORK_NAME=$1
TAG=$2
ARCH_TAG=$3
REGISTRY=$4 # Use the fourth argument as the registry
CONFIG_FILE="scripts/configs/${NETWORK_NAME}.sh"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Configuration file not found: $CONFIG_FILE"
  exit 1
fi

echo "Sourcing configuration from $CONFIG_FILE for network ${NETWORK_NAME}..."
# Source the configuration file to load variables into the current shell
# Use set -a to automatically export sourced variables if needed by subsequent processes
set -a
source "$CONFIG_FILE"
set +a

# Define image name using registry argument
IMAGE_NAME="${REGISTRY}/shardeum/shardeum-validator-${ARCH_TAG}:${NETWORK_NAME}-${TAG}"

echo "Building image: ${IMAGE_NAME} for network ${NETWORK_NAME}"

echo "CHAIN_ID=${CHAIN_ID}"
echo "NEXT_PUBLIC_CHAIN_ID=${NEXT_PUBLIC_CHAIN_ID}"
echo "LOAD_JSON_CONFIGS=${LOAD_JSON_CONFIGS}"
# echo "LOAD_JSON_GENESIS_SECURE_ACCOUNTS=${LOAD_JSON_GENESIS_SECURE_ACCOUNTS}"
# echo "LOAD_JSON_MULTISIG_PERMISSION=${LOAD_JSON_MULTISIG_PERMISSION}"
# echo "LOAD_JSON_GENESIS=${LOAD_JSON_GENESIS}"

# Execute the build command directly substituting shell variables
docker build . \
    --no-cache \
    --build-arg NETWORK="${NETWORK_NAME}" \
    --build-arg VALIDATOR_BRANCH="${VALIDATOR_BRANCH}" \
    --build-arg CLI_BRANCH="${CLI_BRANCH}" \
    --build-arg GUI_BRANCH="${GUI_BRANCH}" \
    --build-arg CHAIN_ID="${CHAIN_ID}" \
    --build-arg NEXT_PUBLIC_CHAIN_ID="${NEXT_PUBLIC_CHAIN_ID}" \
    --build-arg APP_MONITOR="${APP_MONITOR}" \
    --build-arg RPC_SERVER_URL="${RPC_SERVER_URL}" \
    --build-arg EXISTING_ARCHIVERS="${EXISTING_ARCHIVERS}" \
    --build-arg NEXT_PUBLIC_RPC_URL="${NEXT_PUBLIC_RPC_URL}" \
    --build-arg NEXT_PUBLIC_EXPLORER_URL="${NEXT_PUBLIC_EXPLORER_URL}" \
    --build-arg LOAD_JSON_CONFIGS="${LOAD_JSON_CONFIGS}" \
    --build-arg LOAD_JSON_GENESIS_SECURE_ACCOUNTS="${LOAD_JSON_GENESIS_SECURE_ACCOUNTS}" \
    --build-arg LOAD_JSON_MULTISIG_PERMISSION="${LOAD_JSON_MULTISIG_PERMISSION}" \
    --build-arg LOAD_JSON_GENESIS="${LOAD_JSON_GENESIS}" \
    -t "${IMAGE_NAME}"

echo "Docker build completed for ${IMAGE_NAME}" 