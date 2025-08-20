#!/bin/bash

# Branch Configuration
export VALIDATOR_BRANCH="dev"
export CLI_BRANCH="dev"
export GUI_BRANCH="dev"

# Network details
export CHAIN_ID="8080"
export NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID

# External Service Configuration
export APP_MONITOR="104.197.34.69"
export RPC_SERVER_URL="https://api-unstable.shardeum.org"
export EXISTING_ARCHIVERS='[{"ip":"34.57.251.44","port":4000,"publicKey":"f9f0e675e86401a93241130abd8d825485b969d6c545817f87439b7c2b04b3fe"},{"ip":"35.231.169.235","port":4000,"publicKey":"aaeeeb50b20261737542d5ff53f2900f3f740fb3aec04f9c42859efab202da2f"}]'
export NEXT_PUBLIC_RPC_URL="https://api-unstable.shardeum.org"
export NEXT_PUBLIC_EXPLORER_URL="https://explorer-unstable.shardeum.org"

export LOAD_JSON_CONFIGS=/usr/src/app/environments/testnet.config.json
export LOAD_JSON_GENESIS_SECURE_ACCOUNTS=/config/testnet.genesis-secure-accounts.json
export LOAD_JSON_MULTISIG_PERMISSION=/config/testnet.multisig-permissions.json
export LOAD_JSON_GENESIS=/config/testnet.genesis.json



