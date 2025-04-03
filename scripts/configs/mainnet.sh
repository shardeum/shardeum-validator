#!/bin/bash

# Branch Configuration
export VALIDATOR_BRANCH="mainnet-launch"
export CLI_BRANCH="mainnet-launch"
export GUI_BRANCH="mainnet-launch"

# Network details
export CHAIN_ID="8118"
export NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID

## External Service Configuration
export APP_MONITOR="0.0.0.0"
export RPC_SERVER_URL="http://0.0.0.0:8000"
export EXISTING_ARCHIVERS='[{"ip":"0.0.0.0","port":4000,"publicKey":""},{"ip":"0.0.0.0","port":4000,"publicKey":""},{"ip":"0.0.0.0","port":4000,"publicKey":""}]'
export NEXT_PUBLIC_RPC_URL="http://0.0.0.0:8000"
export NEXT_PUBLIC_EXPLORER_URL="http://0.0.0.0:6001"

# Network parameters
export minNodes=256
export baselineNodes=256
export nodesPerConsensusGroup=128
export maxNodes=1280
export enableProblematicNodeRemoval=true
export enableProblematicNodeRemovalOnCycle=0
export flexibleRotationDelta=4
