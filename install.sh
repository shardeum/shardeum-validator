#!/usr/bin/env bash
set -e

read -p "During this early stage of Betanet the Shardeum team will be collecting some performance and debugging info from your node to help improve future versions of the software.
This is only temporary and will be discontinued as we get closer to mainnet.
Thanks for running a node and helping to make Shardeum better.

By running this installer, you agree to allow the Shardeum team to collect this data. (Y/n)?: " WARNING_AGREE

# Echo user's response, or indicate if no response was provided
if [ -z "$WARNING_AGREE" ]; then
    echo "No response provided."
    echo "Defaulting to y"
    WARNING_AGREE=y
else
    echo "You entered: $WARNING_AGREE"
fi

WARNING_AGREE=$(echo "$WARNING_AGREE" | tr '[:upper:]' '[:lower:]')

if [ $WARNING_AGREE != "y" ];
then
  echo "Diagnostic data collection agreement not accepted. Exiting installer."
  exit
fi

echo "If you are upgrading from a previous version, please specify the directory where it was installed."
read -p "What base directory should the node use (default ~/shardeum): " input

# Set default value if input is empty
input=${input:-~/shardeum}

# Reprompt if not alphanumeric characters, tilde, forward slash, underscore, period, hyphen, or contains spaces
while [[ ! $input =~ ^[[:alnum:]_.~/-]+$ || $input =~ [[:space:]] ]]; do
  echo "Error: The directory name contains invalid characters or spaces."
  echo "Allowed characters are alphanumeric characters, tilde (~), forward slash (/), underscore (_), period (.), and hyphen (-)."
  read -p "Please enter a valid base directory (default ~/shardeum): " input

  # Set default if input is empty
  input=${input:-~/.shardeum}
done

# Echo the final directory used (with ~ if present)
echo "The base directory is set to: $input"

# Expand the tilde (~) using a subshell
expanded_input=$(bash -c "echo $input")

# Create the directory if it doesn't exist
mkdir -p "$expanded_input"

# Get the real (absolute) path of the directory
NODEHOME=$(realpath "$expanded_input")

# Check if realpath was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Unable to resolve the real path for '$expanded_input'."
  exit 1
fi

echo "Real path for directory is: $NODEHOME"

command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed on this machine but is required to run the shardeum validator. Please install docker before continuing."; exit 1; }

docker-safe() {
  if ! command -v docker &>/dev/null; then
    echo "docker is not installed on this machine"
    exit 1
  fi

  if ! docker $@; then
    echo "Trying again with sudo..." >&2
    sudo docker $@
  fi
}

if [[ $(docker-safe info 2>&1) == *"Cannot connect to the Docker daemon"* ]]; then
    echo "Docker daemon is not running, please staert the Docker daemon and try again"
    exit 1
else
    echo "Docker daemon is running"
fi

DASHPORT_DEFAULT=8080
EXTERNALIP_DEFAULT=auto
INTERNALIP_DEFAULT=auto
SHMEXT_DEFAULT=9001
SHMINT_DEFAULT=10001

read -p "Do you want to run the web based Dashboard? (Y/n): " RUNDASHBOARD
RUNDASHBOARD=$(echo "$RUNDASHBOARD" | tr '[:upper:]' '[:lower:]')
RUNDASHBOARD=${RUNDASHBOARD:-y}

echo # New line after inputs.

while :; do
  read -p "Enter the port (1025-65536) to access the web based Dashboard (default $DASHPORT_DEFAULT): " DASHPORT
  DASHPORT=${DASHPORT:-$DASHPORT_DEFAULT}
  [[ $DASHPORT =~ ^[0-9]+$ ]] || { echo "Enter a valid port"; continue; }
  if ((DASHPORT >= 1025 && DASHPORT <= 65536)); then
    DASHPORT=${DASHPORT:-$DASHPORT_DEFAULT}
    break
  else
    echo "Port out of range, try again"
  fi
done

while :; do
  read -p "If you wish to set an explicit external IP, enter an IPv4 address (default=$EXTERNALIP_DEFAULT): " EXTERNALIP
  EXTERNALIP=${EXTERNALIP:-$EXTERNALIP_DEFAULT}

  if [ "$EXTERNALIP" == "auto" ]; then
    break
  fi
  # Use regex to check if the input is a valid IPv4 address
  if [[ $EXTERNALIP =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    # Check that each number in the IP address is between 0-255
    valid_ip=true
    IFS='.' read -ra ip_nums <<< "$EXTERNALIP"
    for num in "${ip_nums[@]}"
    do
        if (( num < 0 || num > 255 )); then
            valid_ip=false
        fi
    done
    if [ $valid_ip == true ]; then
      break
    else
      echo "Invalid IPv4 address. Please try again."
    fi
  else
    echo "Invalid IPv4 address. Please try again."
  fi
done

while :; do
  read -p "If you wish to set an explicit internal IP, enter an IPv4 address (default=$INTERNALIP_DEFAULT): " INTERNALIP
  INTERNALIP=${INTERNALIP:-$INTERNALIP_DEFAULT}
  if [ "$INTERNALIP" == "auto" ]; then
    break
  fi
  # Use regex to check if the input is a valid IPv4 address
  if [[ $INTERNALIP =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    # Check that each number in the IP address is between 0-255
    valid_ip=true
    IFS='.' read -ra ip_nums <<< "$INTERNALIP"
    for num in "${ip_nums[@]}"
    do
        if (( num < 0 || num > 255 )); then
            valid_ip=false
        fi
    done
    if [ $valid_ip == true ]; then
      break
    else
      echo "Invalid IPv4 address. Please try again."
    fi
  else
    echo "Invalid IPv4 address. Please try again."
  fi
done

while :; do
  echo "To run a validator on the Shardeum network, you will need to open two ports in your firewall."
  read -p "This allows p2p communication between nodes. Enter the first port (1025-65536) for p2p communication (default $SHMEXT_DEFAULT): " SHMEXT
  SHMEXT=${SHMEXT:-$SHMEXT_DEFAULT}
  [[ $SHMEXT =~ ^[0-9]+$ ]] || { echo "Enter a valid port"; continue; }
  if ((SHMEXT >= 1025 && SHMEXT <= 65536)); then
    SHMEXT=${SHMEXT:-9001}
  else
    echo "Port out of range, try again"
  fi
  read -p "Enter the second port (1025-65536) for p2p communication (default $SHMINT_DEFAULT): " SHMINT
  SHMINT=${SHMINT:-$SHMINT_DEFAULT}
  [[ $SHMINT =~ ^[0-9]+$ ]] || { echo "Enter a valid port"; continue; }
  if ((SHMINT >= 1025 && SHMINT <= 65536)); then
    SHMINT=${SHMINT:-10001}
    break
  else
    echo "Port out of range, try again"
  fi
done


## Remove any previous instance of the validator if it exists
## TODO: Add a check to see if the container is running and prompt the user to stop it
#docker-safe stop shardeum-validator 2>/dev/null
#docker-safe rm shardeum-validator 2>/dev/null

## Make sure the node user can access and write to the shared directory
if [ "$(id -u)" -eq 0 ]; then
    mkdir -p ${NODEHOME} 
    chown 1000:1000 ${NODEHOME} 
fi

docker-safe pull ghcr.io/shardeum/shardeum-validator:latest
docker-safe run \
    --name shardeum-validator \
    -p ${DASHPORT}:${DASHPORT} \
    -p ${SHMEXT}:${SHMEXT} \
    -p ${SHMINT}:${SHMINT} \
    -e RUNDASHBOARD=${RUNDASHBOARD} \
    -e DASHPORT=${DASHPORT} \
    -e EXT_IP=${EXTERNALIP} \
    -e INT_IP=${INTERNALIP} \
    -e SHMEXT=${SHMEXT} \
    -e SHMINT=${SHMINT} \
    -v ${NODEHOME}:/home/node/config \
    --restart=always \
    --detach \
    ghcr.io/shardeum/shardeum-validator

echo "Shardeum Validator starting.."
sleep 4

echo "Enter a new password for the validator dashboard"
${NODEHOME}/set-password.sh

echo "Shardeum Validator is now running. You can access the dashboard at http://${EXTERNALIP}:${DASHPORT}"