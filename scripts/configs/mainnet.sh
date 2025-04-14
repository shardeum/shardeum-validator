#!/bin/bash

# Branch Configuration
export VALIDATOR_BRANCH="mainnet-launch"
export CLI_BRANCH="mainnet-launch"
export GUI_BRANCH="mainnet-launch"

# Network details
export CHAIN_ID="8118"
export NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID

## External Service Configuration
export APP_MONITOR="104.154.117.74"
export RPC_SERVER_URL="http://35.238.62.173:8000"
export EXISTING_ARCHIVERS='[{"ip":"35.238.248.68","port":4000,"publicKey":"e25aa3465e43ecdee2cceddc381d137a4fa4c174144144683e0ea2a42a3801ff"},{"ip":"34.23.94.188","port":4000,"publicKey":"4a6c6ddc9cedb2f4b0ae90a9fd36e705abf572ba971585b429329408bfdfb20e"},{"ip":"34.145.9.44","port":4000,"publicKey":"5278029906ac9b0ae79b96364ef3c7aaa09abd4a36397f0bd5ca7faedd4c575c"}]'
export NEXT_PUBLIC_RPC_URL="http://35.238.62.173:8000"
export NEXT_PUBLIC_EXPLORER_URL="http://34.72.93.203:6001"

export LOAD_JSON_CONFIGS=../../../../../usr/src/app/environments/mainnet.config.json
export LOAD_JSON_GENESIS_SECURE_ACCOUNTS=/config/mainnet.genesis-secure-accounts.json
export LOAD_JSON_MULTISIG_PERMISSION=/config/mainnet.multisig-permissions.json
export LOAD_JSON_GENESIS=/config/mainnet.genesis.json
