#!/bin/bash

# Branch Configuration
export VALIDATOR_BRANCH="mainnet-launch"
export CLI_BRANCH="mainnet-launch"
export GUI_BRANCH="mainnet-launch"

# Network details
export CHAIN_ID="8083"
export NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID

# External Service Configuration
export APP_MONITOR="34.136.247.113"
export RPC_SERVER_URL="https://api-testnet.shardeum.org"
export EXISTING_ARCHIVERS='[{"ip":"34.172.76.241","port":4000,"publicKey":"d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1"}]'
export NEXT_PUBLIC_RPC_URL="http://44.210.15.136:8090"
export NEXT_PUBLIC_EXPLORER_URL="https://explorer-testnet.shardeum.org"

export LOAD_JSON_CONFIGS=/usr/src/app/environments/testnet.config.json
export LOAD_JSON_GENESIS_SECURE_ACCOUNTS=/config/testnet.genesis-secure-accounts.json
export LOAD_JSON_MULTISIG_PERMISSION=/config/testnet.multisig-permissions.json
export LOAD_JSON_GENESIS=/config/testnet.genesis.json
