#!/bin/bash

# Branch Configuration
export VALIDATOR_BRANCH="dev"
export CLI_BRANCH="dev"
export GUI_BRANCH="dev"

# Network details
export CHAIN_ID="8082"
export NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID

# External Service Configuration
export APP_MONITOR="34.75.10.66"
export RPC_SERVER_URL="http://34.148.186.123:8000"
export EXISTING_ARCHIVERS='[{"ip":"35.229.75.252","port":4000,"publicKey":"2db7c949632d26b87d7e7a5a4ad41c306f63ee972655121a37c5e4f52b00a542"}]'
export NEXT_PUBLIC_RPC_URL="http://34.148.186.123:8000"
export NEXT_PUBLIC_EXPLORER_URL="https://explorer-devnetus.shardeum.org"

export LOAD_JSON_CONFIGS=/usr/src/app/environments/devnet.config.json
export LOAD_JSON_GENESIS_SECURE_ACCOUNTS=/config/devnet.genesis-secure-accounts.json
export LOAD_JSON_MULTISIG_PERMISSION=/config/devnet.multisig-permissions.json
export LOAD_JSON_GENESIS=/config/devnet.genesis.json