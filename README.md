# Shardeum Validator
The validator which allows you to participate in the Shardeum network and earn SHM

To run the Shardeum Validator you'll need to have Docker installed on your machine. You can find instructions on how to install Docker [here](https://docs.docker.com/get-docker/). Then run the following command to start the validator:

```bash
docker pull ghcr.io/shardeum/shardeum-validator
docker run \
    --name shardeum-validator \
    -p 8080:8080 \
    -p 9001:9001 \
    -p 10001:10001 \
    -v $(pwd)/shardeum:/home/node/config \
    --restart=always \
    --detach \
    ghcr.io/shardeum/shardeum-validator
```

This will start the validator with the default ports, 8080 for the dashboard GUI, and 9001 and 10001 for the validator P2P ports. The validator will store its data in the `~/shardeum` directory on your machine. You can change this to any directory you like by changing the `-v` argument.

You can set the password for the dashboard GUI using the set-password.sh script in the ~/shardeum folder:
```bash
cd ~/shardeum
./set-password.sh
```


## Important
You'll have to open the ports used on your firewall to allow incoming connections to the validator and/or redirect these ports to your machine on your home router.

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
    -v $(pwd)/shardeum:/home/node/config \
    --restart=always \
    --detach \
    ghcr.io/shardeum/shardeum-validator
```

These are the environment variables used by the validator:

```bash
APP_MONITOR RPC_SERVER_URL EXISTING_ARCHIVERS NEXT_PUBLIC_RPC_URL NEXT_EXPLORER_URL INT_IP SHMINT SHMEXT DASHPORT RUNDASHBOARD EXT_IP SERVERIP LOCALLANIP
```

So you could, for example, run the validator without starting the dashboard by specifying `-e RUNDASHBOARD=n` in the docker run command.


# Running the validator on other networks

You can override the network configs the image was build with by setting the following environment variables:

```bash
docker run \
    --name shardeum-validator \
    -p 8080:8080 \
    -p 9001:9001 \
    -p 10001:10001 \
    -v $(pwd)/shardeum:/home/node/config \
    -e RPC_SERVER_URL='http://localhost:123' \
    -e APP_MONITOR='http://localhost:456' \
    -e EXISTING_ARCHIVERS='[{"ip":"127.0.0.1","port":4000,"publicKey":"somekeygoeshere"}]' \
    -e EXT_IP='192.168.0.1' \
    ghcr.io/shardeum/shardeum-validator
```

## Running on other platforms
The end user experience is kept as closely to the old installer as possible, The command looks similar but does has a different url. Make sure to use this new one:

curl -O https://raw.githubusercontent.com/shardeum/shardeum-validator/refs/heads/dev/install.sh && chmod +x install.sh && ./install.sh

Because the new build system is fully Docker based, the install.sh script is really only there to make it easier to enter ports and other preferences, however it's just as effective to run it directly as docker command, ie:

```
docker pull ghcr.io/shardeum/shardeum-validator
docker run \
    --name shardeum-validator \
    -p 8080:8080 \
    -p 9001:9001 \
    -p 10001:10001 \
    -v $(pwd)/shardeum:/home/node/config \
    --restart=always \
    --detach \
    ghcr.io/shardeum/shardeum-validator:latest
docker exec -it shardeum-validator operator-cli gui set password "YOUR_NEW_PASSWORD"
```

This same command will work on Windows, Mac and Linux on both X86_64 and ARM64 platforms. 

There's additional info on how to specify different ports and other settings, that can all be controlled through ENV vars, in the shardeum-validator README: 
https://github.com/shardeum/shardeum-validator?tab=readme-ov-file#shardeum-validator

## Changing Validator, CLI and GUI branches to build


The build script parses which branches to build through env variables, update these to the correct branch for the network:
https://github.com/shardeum/shardeum-validator/blob/dev/build.sh

In this example it will build the it4-1.16.1 branch of the validator, and main branches for the validator CLI and GUI:

```
docker build . \
    --push \
    --no-cache \
    --build-arg VALIDATOR_BRANCH=it4-1.16.1 \
    --build-arg CLI_BRANCH=main \
    --build-arg GUI_BRANCH=main \
    -t ghcr.io/shardeum/shardeum-validator-${ARCH_TAG}:${TAG}
```

## Changing network settings


The defaults used by the build are specified in the Dockerfile, this includes the archivers, explorer, rpc and monitor. Make sure to update these for the current network before building:
https://github.com/shardeum/shardeum-validator/blob/dev/Dockerfile

```
## Network details
ARG APP_MONITOR="34.28.123.3"
ARG RPC_SERVER_URL="http://34.42.232.167:8000 "
ARG EXISTING_ARCHIVERS='[{"ip":"35.193.191.159","port":4000,"publicKey":"1c63734aedef5665d6cf02d3a79ae30aedcbd27eae3b76fff05d587a6ac62981"},{"ip":"34.73.94.45","port":4000,"publicKey":"11086314ccf8642906b99f09cf3ae9a13370c57106653cd28fc1a9eee2560b64"},{"ip":"34.19.93.147","port":4000,"publicKey":"b09a8792593682cbffbbf2fc3bd812d8143740197a5f435c77a38740397088ac"}]'
ARG NEXT_PUBLIC_RPC_URL="http://34.42.232.167:8000 "
ARG NEXT_EXPLORER_URL="http://35.238.111.77:6001"
ARG SHMEXT=9001
ARG SHMINT=10001
ARG DASHPORT=8080
ARG RUNDASHBOARD="y"
ARG INT_IP="auto"
ARG LOCALLANIP="auto"
ARG EXT_IP="auto"
ARG SERVERIP="auto"

## These should not be changed often or easily without thourough testing
## 6 Gigabytes of memory for the node process for the validator to deal with the large amount of data it has to be able to handle
ARG NODE_OPTIONS="--max-old-space-size=6144"
ARG minNodes=1280
ARG baselineNodes=1280
ARG nodesPerConsensusGroup=128
ARG maxNodes=1500
```

## Building

For each build that is to be published use a new tag, currently I'm using itn4-{build number} ie itn-7, this will result in an image that can be pulled with docker pull ghcr.io/shardeum/shardeum-validator:itn4-7

Each build has to be done on both an x86_64 and arm64 linux platform. Docker desktop for mac and windows add an extra layer to the image that makes it unusable in the next step of publishing a manifest for both architectures

On both build systems run the following commands to build and publish the new version. The build script will auto-detect wether its an amd64 or arm64 system so this doesn't have to be specified:
https://github.com/shardeum/shardeum-validator/blob/dev/build.sh
```
gh repo clone shardeum/shardeum-validator
cd shardeum-validator
./build.sh itn4-10
```
If the build completes successfully it will push the image to the github container registry, ghcr.io. If you are not authenticated to the ghcr you can do so by running (replacing USERNAME with your github username, and TOKEN with a personal access token that has all the required permissions to publish packages):
```
echo "TOKEN" | docker login ghcr.io -u USERNAME --password-stdin
```
Once the builds have completed & pushed the builds to ghcr.io on both the amd64 and arm64 systems, the next step is to create a manifest

The manifest is where the separate platform images, ie ghcr.io/shardeum/shardeum-validator-arm64:itn4-10 and ghcr.io/shardeum/shardeum-validator-amd:itn4-10 are combined into one image where docker will automatically pull the correct OS/ARCH version for the platform it's run on. See https://github.com/shardeum/shardeum-validator/pkgs/container/shardeum-validator for the manifest listings. This manifest based image name is used by the installer, which uses the :latest version by default

Creating the manifests and tagging it and the images as :latest is a bunch of commands, so you can use the tag.sh script to perform all these actions for you
https://github.com/shardeum/shardeum-validator/blob/dev/tag.sh
```
./tag.sh itn4-10
```

Run this on a system where you are authenticated to ghcr.io, however it does not have to be one of the build systems it'll download the amd64 and arm64 images for you

Once it's completed the latest build is available in https://github.com/shardeum/shardeum-validator/pkgs/container/shardeum-validator tagged as :latest and can be pulled with 
```
docker pull ghcr.io/shardeum/shardeum-validator:latest
```
