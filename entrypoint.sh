#!/usr/bin/env bash

## Pick up existing environment variables if already set
if [ -f /home/node/env ]; then
    echo "Loading existing env"
    . /home/node/env
    echo "New env:"
    export
fi

get_net_ip() {
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
    external_ip=$(get_net_ip)
    if [ $? -eq 0 ]; then
      echo "The IP address is: $IP"
    else
      external_ip="localhost"
    fi
  fi
  echo $external_ip
}


## Autodetect the external IP address if none is provided or set to "auto", which is the Dockerfile default
if [ -z "$EXT_IP" ] || [ "$EXT_IP" = "auto" ]; then
    EXT_IP=$(get_external_ip)
fi
SERVERIP=$EXT_IP

if [ -z "$INT_IP" ] || [ "$INT_IP" = "auto" ]; then
  INT_IP=$EXT_IP
fi
LOCALLANIP=$INT_IP


## If the env file does not exist, create it so they're loaded automatically next time the container is started
if [ ! -f /home/node/env ]; then
    echo "Creating env file"
    cat >/home/node/env <<EOL
INT_IP="$INT_IP"
EXT_IP="$EXT_IP"
SERVERIP="$SERVERIP"
LOCALLANIP="$LOCALLANIP"
EOL
fi

export APP_MONITOR RPC_SERVER_URL EXISTING_ARCHIVERS NEXT_PUBLIC_RPC_URL NEXT_EXPLORER_URL INT_IP SHMEXT SHMINT DASHPORT RUNDASHBOARD EXT_IP SERVERIP
echo "Env vars:"
export

## Copy the shell scripts to the config directory if they don't exist
if [ ! -f /home/node/app/set-password.sh ]; then
  cp -f /home/node/app/set-password.sh /home/node/app/shell.sh /home/node/app/operator-cli.sh /home/node/config/
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
