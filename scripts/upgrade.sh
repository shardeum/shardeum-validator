#!/usr/bin/env bash

CONTAINER_NAME="shardeum-validator"
IMAGE="ghcr.io/shardeum/shardeum-validator:latest"

docker-safe() {
  if ! command -v docker &>/dev/null; then
    echo "docker is not installed on this machine"
    exit 1
  fi

  if ! docker $@; then
    echo "Trying again with sudo..."
    sudo docker $@
  fi
}

# Step 1: Check if the container is running
CONTAINER_ID=$(docker-safe ps -q --filter "name=$CONTAINER_NAME")
if [ -z "$CONTAINER_ID" ]; then
  echo "No running container found with name: $CONTAINER_NAME"
  exit 1
fi

# Step 2: Extract current configuration
echo "Extracting current configuration from $CONTAINER_NAME..."
PORTS=$(docker inspect "$CONTAINER_ID" --format '{{range $p, $conf := .HostConfig.PortBindings}}-p {{$p}} {{end}}' | xargs -n1 | paste -sd' ' -)
ENV_VARS=$(docker inspect "$CONTAINER_ID" --format '{{range .Config.Env}}-e {{.}} {{end}}')
VOLUMES=$(docker inspect "$CONTAINER_ID" --format '{{range .Mounts}}-v {{.Source}}:{{.Destination}} {{end}}')

# Step 3: Stop and remove the current container
echo "Stopping and removing the current container..."
docker-safe stop "$CONTAINER_ID" 1>/dev/null
docker-safe rm "$CONTAINER_ID" 1>/dev/null

# Step 4: Pull the latest image
echo "Pulling the latest image: $IMAGE..."
docker-safe pull "$IMAGE"

# Step 5: Run the new container with the same configuration
echo "Starting the new container with the same configuration..."
docker-safe run \
  --name "$CONTAINER_NAME" \
  $PORTS \
  $ENV_VARS \
  $VOLUMES \
  --restart=always \
  --detach \
  "$IMAGE" 1>/dev/null

if [ $? -eq 0 ]; then
  echo "Upgrade successful! The new container is now running."
else
  echo "Upgrade failed. Please check the logs and try again."
  exit 1
fi