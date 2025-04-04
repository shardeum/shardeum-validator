#!/bin/bash

# Required Environment Variables (values here are from testnet)
CHAIN_ID=8083
NEXT_PUBLIC_CHAIN_ID=${CHAIN_ID}
APP_MONITOR="34.56.47.170"
RPC_SERVER_URL="https://api-testnet.shardeum.org"
EXISTING_ARCHIVERS='[{"ip":"104.197.117.164","port":4000,"publicKey":"d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1"},{"ip":"34.139.3.222","port":4000,"publicKey":"1c42a7f9cca36e13e590ae00c1124c5a1f696c879da210ffcdccb312d08c8214"},{"ip":"35.233.192.167","port":4000,"publicKey":"d1721c924394ae1ff3e9ea22af15962e045511fde05ed0b56f0a8c36eb161d75"}]'
NEXT_PUBLIC_RPC_URL="https://api-testnet.shardeum.org"
NEXT_PUBLIC_EXPLORER_URL="https://explorer-testnet.shardeum.org"
minNodes=256
baselineNodes=256
nodesPerConsensusGroup=128
maxNodes=1280
enableProblematicNodeRemoval=true
enableProblematicNodeRemovalOnCycle=0
flexibleRotationDelta=4
VALIDATOR_BRANCH=mainnet-launch
CLI_BRANCH=mainnet-launch
GUI_BRANCH=mainnet-launch

if [ -z "$1" ]; then
    echo "No tag provided. Exiting."
    exit 1
fi
TAG=$1

# Determine the architecture
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

# Check for required environment variables
required_vars=(
    VALIDATOR_BRANCH
    CLI_BRANCH
    GUI_BRANCH
    CHAIN_ID
    NEXT_PUBLIC_CHAIN_ID
    APP_MONITOR
    RPC_SERVER_URL
    EXISTING_ARCHIVERS
    NEXT_PUBLIC_RPC_URL
    NEXT_PUBLIC_EXPLORER_URL
    minNodes
    baselineNodes
    nodesPerConsensusGroup
    maxNodes
    enableProblematicNodeRemoval
    enableProblematicNodeRemovalOnCycle
    flexibleRotationDelta
)

missing_vars=()
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -gt 0 ]; then
  echo "ERROR: Missing required environment variables:"
  printf '%s\n' "${missing_vars[@]}"
  exit 1
fi

# Build and tag the image
docker build . \
    --push \
    --no-cache \
    --build-arg VALIDATOR_BRANCH=${VALIDATOR_BRANCH} \
    --build-arg CLI_BRANCH=${CLI_BRANCH} \
    --build-arg GUI_BRANCH=${GUI_BRANCH} \
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
    -t ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}

echo "Build complete: ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}"
