#!/bin/bash

set -e

# Check if network name, tag, and arch_tag are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <network_name> <tag> <arch_tag>"
  echo "Example: $0 testnet v1.0.0 amd64"
  exit 1
fi

NETWORK_NAME=$1
TAG=$2
ARCH_TAG=$3
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

# Define image name
IMAGE_NAME="ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}"

echo "Building image: ${IMAGE_NAME}"

# Execute the build command directly substituting shell variables
docker build . \
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
    --build-arg minNodes="${minNodes}" \
    --build-arg baselineNodes="${baselineNodes}" \
    --build-arg nodesPerConsensusGroup="${nodesPerConsensusGroup}" \
    --build-arg maxNodes="${maxNodes}" \
    --build-arg enableProblematicNodeRemoval="${enableProblematicNodeRemoval}" \
    --build-arg enableProblematicNodeRemovalOnCycle="${enableProblematicNodeRemovalOnCycle}" \
    --build-arg flexibleRotationDelta="${flexibleRotationDelta}" \
    -t "${IMAGE_NAME}"

echo "Docker build completed for ${IMAGE_NAME}" 