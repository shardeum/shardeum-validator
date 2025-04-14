#!/bin/bash

# Branch Configuration
export VALIDATOR_BRANCH="mainnet-launch"
export CLI_BRANCH="mainnet-launch"
export GUI_BRANCH="mainnet-launch"

# Network details
export CHAIN_ID="8081"
export NEXT_PUBLIC_CHAIN_ID=$CHAIN_ID

# External Service Configuration
export APP_MONITOR="34.16.2.42"
export RPC_SERVER_URL="https://api-stagenet.shardeum.org"
export EXISTING_ARCHIVERS='[{"ip":"34.57.177.170","port":4000,"publicKey":"d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1"},{"ip":"34.73.104.156","port":4000,"publicKey":"37d162292c068030bbde55ee8ac777ad08f443b9bba0b0064e4919345d43727a"},{"ip":"35.230.76.119","port":4000,"publicKey":"d8475a2d2110becb2d031085a2915956239dafcafd2d57f5468a187bb7235dd7"}]'
export NEXT_PUBLIC_RPC_URL="https://api-stagenet.shardeum.org"
export NEXT_PUBLIC_EXPLORER_URL="https://explorer-stagenet.shardeum.org"

export LOAD_JSON_CONFIGS=/usr/src/app/environments/stagenet.config.json
export LOAD_JSON_GENESIS_SECURE_ACCOUNTS=/config/stagenet.genesis-secure-accounts.json
export LOAD_JSON_MULTISIG_PERMISSION=/config/stagenet.multisig-permissions.json
export LOAD_JSON_GENESIS=/config/stagenet.genesis.json
