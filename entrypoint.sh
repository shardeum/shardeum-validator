#!/usr/bin/env bash

## Pick up existing environment variables if already set
if [ -f /home/node/config/env ]; then
    . /home/node/config/env
fi

## Network specific settings, change these for every network relaunch

APP_MONITOR=${APP_MONITOR:-"54.185.250.216"}
RPC_SERVER_URL=${RPC_SERVER_URL:-"https://atomium.shardeum.org"}
EXISTING_ARCHIVERS=${EXISTING_ARCHIVERS:-"[{\"ip\":\"34.68.218.222\",\"port\":4000,\"publicKey\":\"64a3833499130406550729ab20f6bec351d04ec9be3e5f0144d54f01d4d18c45\"},{\"ip\":\"34.174.86.241\",\"port\":4000,\"publicKey\":\"9b4ba46439ea6cafc6b20d971ab0ef0f21b415c27482652efac96fd61a76d73c\"},{\"ip\":\"34.48.51.73\",\"port\":4000,\"publicKey\":\"ea72ef63e27cb960bfe02f17d40e74b5c28437af1d0df83dd21ba2084596789f\"}]"}
NEXT_PUBLIC_RPC_URL=${NEXT_PUBLIC_RPC_URL:-"https://atomium.shardeum.org"}
NEXT_EXPLORER_URL=${NEXT_EXPLORER_URL:-"https://explorer-atomium.shardeum.org"}

## Use the values parsed from the docker run env variables, or set defaults
INT_IP=${INT_IP:-"auto"}
SHMEXT=${SHMEXT:-9001}
SHMINT=${SHMINT:-10001}
DASHPORT=${DASHPORT:-8080}
RUNDASHBOARD=${RUNDASHBOARD:-"y"}


get_ip() {
  local ip
  if command -v ip >/dev/null; then
    ip=$(ip addr show $(ip route | awk '/default/ {print $5}') | awk '/inet/ {print $2}' | cut -d/ -f1 | head -n1)
  elif command -v netstat >/dev/null; then
    # Get the default route interface
    interface=$(netstat -rn | awk '/default/{print $4}' | head -n1)
    # Get the IP address for the default interface
    ip=$(ifconfig "$interface" | awk '/inet /{print $2}')
  else
    echo "Error: neither 'ip' nor 'ifconfig' command found. Submit a bug for your OS."
    return 1
  fi
  echo $ip
}


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
if [ -z "$LOCALLANIP" ]; then
    LOCALLANIP=$(get_ip)
fi


## If the env file does not exist, create it so they're loaded automatically next time the container is started
if [ ! -f /home/node/config/env ]; then
    cat >/home/node/config/env <<EOL
APP_MONITOR=$APP_MONITOR
RPC_SERVER_URL=$RPC_SERVER_URL
EXISTING_ARCHIVERS=$EXISTING_ARCHIVERS
NEXT_PUBLIC_RPC_URL=$NEXT_PUBLIC_RPC_URL
NEXT_EXPLORER_URL=$NEXT_EXPLORER_URL
INT_IP=$INT_IP
SHMEXT=$SHMEXT
SHMINT=$SHMINT
DASHPORT=$DASHPORT
RUNDASHBOARD=$RUNDASHBOARD
EXT_IP=$EXT_IP
SERVERIP=$SERVERIP
export APP_MONITOR RPC_SERVER_URL EXISTING_ARCHIVERS NEXT_PUBLIC_RPC_URL NEXT_EXPLORER_URL INT_IP SHMEXT SHMINT DASHPORT RUNDASHBOARD EXT_IP SERVERIP
EOL
fi


## Ensure the certificates for the GUI exist in the config directory

if [ ! -f "/home/node/config/CA.cnf" ]; then
    cd /home/node/config
    echo "Creating certificates"

    echo "[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = XX
ST = Localzone
L = localhost
O = Certificate Authority Local Validator Node
OU = Develop
CN = mynode-atomium.sharedum.local
emailAddress = community@.sharedum.local" > CA.cnf

    openssl req -nodes -new -x509 -keyout CA_key.pem -out CA_cert.pem -days 1825 -config CA.cnf > /dev/null

echo "[ req ]
default_bits  = 4096
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = XX
stateOrProvinceName = Localzone
localityName = Localhost
organizationName = Shardeum Atomium 1.x Validator Cert.
commonName = localhost

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $SERVERIP
IP.2 = $LOCALLANIP
DNS.1 = localhost" > selfsigned.cnf

    openssl req -sha256 -nodes -newkey rsa:4096 -keyout selfsigned.key -out selfsigned.csr -config selfsigned.cnf > /dev/null

    openssl x509 -req -days 398 -in selfsigned.csr -CA CA_cert.pem -CAkey CA_key.pem -CAcreateserial -out selfsigned_node.crt -extensions req_ext -extfile selfsigned.cnf > /dev/null

    cat selfsigned_node.crt CA_cert.pem > selfsigned.crt

fi

## Start the GUI if enabled
if [ "$RUNDASHBOARD" = "y" ]; then
    echo "Starting validator GUI"
    operator-cli gui start
fi

## Keep the container running
cd /home/node/app
pm2 logs
