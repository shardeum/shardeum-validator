#!/usr/bin/env bash

## Network specific settings, change these for every network relaunch
APP_MONITOR=54.185.250.216
RPC_SERVER_URL=https://atomium.shardeum.org
EXISTING_ARCHIVERS='[{"ip":"34.68.218.222","port":4000,"publicKey":"64a3833499130406550729ab20f6bec351d04ec9be3e5f0144d54f01d4d18c45"},{"ip":"34.174.86.241","port":4000,"publicKey":"9b4ba46439ea6cafc6b20d971ab0ef0f21b415c27482652efac96fd61a76d73c"},{"ip":"34.48.51.73","port":4000,"publicKey":"ea72ef63e27cb960bfe02f17d40e74b5c28437af1d0df83dd21ba2084596789f"}]'
NEXT_PUBLIC_RPC_URL=https://atomium.shardeum.org
NEXT_EXPLORER_URL=https://explorer-atomium.shardeum.org


## Use the values parsed from the docker run env variables, or set defaults
INT_IP=${INT_IP:-"auto"}
SHMEXT=${SHMEXT:-9001}
SHMINT=${SHMINT:-10001}
DASHPORT=${DASHPORT:-8080}
RUNDASHBOARD=${RUNDASHBOARD:-"y"}


get_external_ip() {
  external_ip=''
  external_ip=$(curl -s https://api.ipify.org)
  if [[ -z "$external_ip" ]]; then
    external_ip=$(curl -s http://checkip.dyndns.org | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
  fi
  if [[ -z "$external_ip" ]]; then
    external_ip=$(curl -s http://ipecho.net/plain)
  fi
  if [[ -z "$external_ip" ]]; then
    external_ip=$(curl -s https://icanhazip.com/)
  fi
    if [[ -z "$external_ip" ]]; then
    external_ip=$(curl --header  "Host: icanhazip.com" -s 104.18.114.97)
  fi
  if [[ -z "$external_ip" ]]; then
    external_ip=$(get_ip)
    if [ $? -eq 0 ]; then
      echo "The IP address is: $IP"
    else
      external_ip="localhost"
    fi
  fi
  echo $external_ip
}


## Autodetect the external IP address if none is provided
if [ -z "$EXT_IP" ]; then
    EXT_IP=$(get_external_ip)
fi
SERVERIP=$EXT_IP

## Make variables available to the CLI app which uses them to start the validator
export APP_MONITOR RPC_SERVER_URL EXISTING_ARCHIVERS NEXT_PUBLIC_RPC_URL NEXT_EXPLORER_URL INT_IP SHMEXT SHMINT DASHPORT RUNDASHBOARD EXT_IP SERVERIP

## Ensure that the env variables are set for the node user on any shell session
ENV_VARS=(
  "APP_MONITOR"
  "RPC_SERVER_URL"
  "EXISTING_ARCHIVERS"
  "NEXT_PUBLIC_RPC_URL"
  "NEXT_EXPLORER_URL"
  "INT_IP"
  "SHMEXT"
  "SHMINT"
  "DASHPORT"
  "RUNDASHBOARD"
  "EXT_IP"
  "SERVERIP"
)

# Path to the profile file
PROFILE_FILE="$HOME/.profile"

# Loop through each variable and append it to ~/.profile if not already present
for VAR in "${ENV_VARS[@]}"; do
  # Check if the variable is already in the profile
  if ! grep -q "^export $VAR=" "$PROFILE_FILE"; then
    # Add the variable to ~/.profile
    echo "export $VAR=\${$VAR}" >> "$PROFILE_FILE"
  fi
done

## Ensure the certificates for the GUI exist in the config directory
cd /usr/home/config
if [ ! -f "CA.cnf" ]; then
    echo "Creating certificates"
    # Redirect stdout to /dev/null to avoid printing the openssl cruft, but show stderr errors as they could be useful for debugging
    ./create-certificates.sh > /dev/null
fi

## Start the GUI if enabled
if [ "$RUNDASHBOARD" = "y" ]; then
    echo "Starting validator GUI"
    operator-cli gui start
fi

## Keep the container running
cd /home/node/app
pm2 logs
