#!/bin/bash

# Branch Configuration
export VALIDATOR_BRANCH="mainnet-launch"
export CLI_BRANCH="mainnet-launch"
export GUI_BRANCH="mainnet-launch"

# Network details
export CHAIN_ID="8083"
export NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID

# External Service Configuration
export APP_MONITOR="34.56.47.170"
export RPC_SERVER_URL="https://api-testnet.shardeum.org"
export EXISTING_ARCHIVERS='[{"ip":"104.197.117.164","port":4000,"publicKey":"d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1"},{"ip":"34.139.3.222","port":4000,"publicKey":"1c42a7f9cca36e13e590ae00c1124c5a1f696c879da210ffcdccb312d08c8214"},{"ip":"35.233.192.167","port":4000,"publicKey":"d1721c924394ae1ff3e9ea22af15962e045511fde05ed0b56f0a8c36eb161d75"}]'
export NEXT_PUBLIC_RPC_URL="https://api-testnet.shardeum.org"
export NEXT_PUBLIC_EXPLORER_URL="https://explorer-testnet.shardeum.org"

# Network parameters
export minNodes=256
export baselineNodes=256
export nodesPerConsensusGroup=128
export maxNodes=1280
export enableProblematicNodeRemoval=true
export enableProblematicNodeRemovalOnCycle=0
export flexibleRotationDelta=4
