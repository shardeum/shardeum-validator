# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Shardeum validator node Docker container repository. It builds and packages three components into a single Docker image:
- Validator core (from shardeum/shardeum)
- Validator CLI (from shardeum/validator-cli)
- Validator GUI dashboard (from shardeum/validator-gui)

## Common Commands

### Building
```bash
# Build for current architecture (auto-detects amd64/arm64)
./build.sh <tag>

# Build for specific network and architecture
./scripts/build-network.sh <network> <tag> <arch> <registry>
# Example: ./scripts/build-network.sh testnet v1.0.0 amd64 ghcr.io/shardeum

# Create multi-arch manifest after building both architectures
./tag.sh <tag>
```

### Running
```bash
# Install and run validator (interactive setup)
./install.sh

# Direct Docker run
docker run --name shardeum-node -p 8080:8080 -p 9001:9001 -p 10001:10001 ghcr.io/shardeum/shardeum-validator:<tag>
```

### Vulnerability Scanning
```bash
./scan-vuln.sh
```

## Architecture

The project uses a multi-stage Docker build:
1. **validator-build**: Builds the core validator from source (Node.js 18.19.1, Rust 1.74.1)
2. **cli-build**: Builds the validator CLI
3. **gui-build**: Builds the web dashboard
4. **runtime**: Final slim image combining all components

Key process management:
- PM2 manages both validator and GUI processes
- Validator runs with 6GB memory allocation
- Log rotation configured via PM2 ecosystem

## Network Configurations

Three networks are supported, each with specific configurations in `scripts/configs/`:
- **testnet**: Chain ID 8083, RPC server rpc-testnet.shardeum.org
- **stagenet**: Chain ID 8084, RPC server rpc-stagenet.shardeum.org  
- **mainnet**: Chain ID 8118, RPC server mainnet.shardeum.org

## GitHub Actions Workflows

Two main workflows:
1. **build-images.yml**: Builds Docker images for specified networks and branches
2. **promote-latest.yml**: Tags images as 'latest' for production use

Workflow inputs allow specifying branches for each component (validator, CLI, GUI).

## Key Environment Variables

When running the validator:
- `SHMEXT`: External port (default 9001)
- `SHMINT`: Internal port (default 10001)
- `DASHPORT`: Dashboard port (default 8080)
- `RUNDASHBOARD`: Enable/disable GUI (default 1)
- `APP_IP`: Public IP address
- `EXISTING_ARCHIVERS`: Archiver list URL

## Development Notes

- No unit tests in this repository - testing happens at integration level
- No linting configuration - code quality managed in upstream repositories
- Docker-based deployment focus - not meant for local development of components
- Always tag images with semantic versions, use 'latest' only for stable releases
- Multi-arch support required (amd64 and arm64)