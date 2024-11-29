# Shardeum Validator
The validator which allows you to participate in the Shardeum network and earn SHM

To run the Shardeum Validator you'll need to have Docker installed on your machine. You can find instructions on how to install Docker [here](https://docs.docker.com/get-docker/). Then run the following command to start the validator:

```bash
docker run \
    --name shardeum-validator \
    -p 8080:8080 \
    -p 9001:9001 \
    -p 10001:10001 \
    -v ~/shardeum:/home/node/app/config \
    --restart=always \
    --detach \
    shardeum-validator
```

This will start the validator with the default ports, 8080 for the dashboard GUI, and 9001 and 10001 for the validator P2P ports. The validator will store its data in the `~/shardeum` directory on your machine. You can change this to any directory you like by changing the `-v` argument.

You can set the password for the dashboard GUI using the set-password.sh script in the ~/shardeum folder:
```bash
cd ~/shardeum
./set-password.sh
```


## Important
You'll have to open these ports on your firewall to allow incoming connections to the validator and/or redirect these ports to your machine on your home router.

# Configuring ports and other settings

You can change the ports the validator uses by setting the following environment variables & adjusting your docker run command accordingly ,this example would change the ports to 10080 for the dashboard GUI, and use 11001, 12002 for the validator P2P ports:

```bash
docker run \
    --name validator-dashboard \
    -p 10080:10080 \
    -p 11001:11001 \
    -p 12002:12002 \
    -e SHMINT=11001 \
    -e SHMEXT=12002 \
    -e DASHPORT=10080 \
    -v ~/shardeum:/home/node/app/config \
    --restart=always \
    --detach \
    shardeum-validator
```

These are the environment variables used by the validator:

```bash
APP_MONITOR RPC_SERVER_URL EXISTING_ARCHIVERS NEXT_PUBLIC_RPC_URL NEXT_EXPLORER_URL INT_IP SHMINT SHMEXT DASHPORT RUNDASHBOARD EXT_IP SERVERIP
```

# Running the validator on other networks

You can override the network configs the image was build with by setting the following environment variables:

```bash
docker run \
    --name shardeum-validator \
    -p 8080:8080 \
    -p 9001:9001 \
    -p 10001:10001 \
    -v ~/shardeum:/home/node/app/config \
    -e RPC_SERVER_URL='http://localhost:123' \
    -e APP_MONITOR='http://localhost:456' \
    -e EXISTING_ARCHIVERS='[{"ip":"127.0.0.1","port":4000,"publicKey":"somekeygoeshere"}]' \
    -e EXT_IP='192.168.0.1' \
    shardeum-validator

```

# Building an image

First ensure the defaults at the top of entrypoint.sh are set correctly for the RPC server, monitor and archivers as these will be hard coded in the image.

You can specify which shardeum server, validator GUI and CLI branches to build through these build arguments:

```bash
docker build . --build-arg VALIDATOR_BRANCH=dev --build-arg CLI_BRANCH=dev --build-arg GUI_BRANCH=dev -t shardeum-validator 
```

## Building a multi-arch release

This will use buildx to build the image for both amd64 and arm64 architectures and push it to the specified repository:

```bash
docker buildx build \
   --build-arg VALIDATOR_BRANCH=dev \
   --build-arg CLI_BRANCH=dev \
   --build-arg GUI_BRANCH=dev \
   --platform linux/amd64,linux/arm64 \
   --push \
   -t github.com/shardeum/shardeum-validator \
   .
```