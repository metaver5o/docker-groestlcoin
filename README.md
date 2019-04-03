# Docker-Groestlcoin

[![Build Status](https://img.shields.io/travis/NicolasDorier/docker-bitcoin.svg)](https://travis-ci.org/NicolasDorier/docker-bitcoin)
[![License](https://img.shields.io/github/license/NicolasDorier/docker-bitcoin.svg)](https://github.com/NicolasDorier/docker-bitcoin/blob/master/LICENSE)

Groestlcoin uses peer-to-peer technology to operate with no central authority or banks; managing transactions and the issuing of Groestlcoin is carried out collectively by the network. Groestlcoin is open-source; its design is public, nobody owns or controls Groestlcoin and everyone can take part. Through many of its unique properties, Groestlcoin allows exciting uses that could not be covered by any previous payment system.

This Docker image provides `groestlcoin`, `groestlcoin-cli` and `groestlcoin-tx` applications which can be used to run and interact with a groestlcoin server.

Images are provided for a range of current and historic Bitcoin forks.
To see the available versions/tags, please visit the appropriate pages on Docker Hub:

* [Bitcoin Core](https://hub.docker.com/r/NicolasDorier/bitcoin/tags/)
* [Bitcoin Classic](https://hub.docker.com/r/NicolasDorier/bitcoinclassic/tags/)
* [Bitcoin Unlimited](https://hub.docker.com/r/NicolasDorier/bitcoinunlimited/tags/)
* [Bitcoin XT](https://hub.docker.com/r/NicolasDorier/bitcoinxt/tags/)
* [btc1 Core](https://hub.docker.com/r/NicolasDorier/btc1/tags/)

### Usage

To start a groestlcoind instance running the latest version:

```
$ docker run Groestlcoin/groestlcoin
```

This docker image provides different tags so that you can specify the exact version of groestlcoin you wish to run. For example, to run the latest minor version in the `2.16.x` series (currently `2.16.3`):

```
$ docker run Groestlcoin/groestlcoin:2.16
```

Or, to run the `2.16.0` release specifically:

```
$ docker run Groestlcoin/groestlcoin:2.16.0
```

To run a Groestlcoin container in the background, pass the `-d` option to `docker run`, and give your container a name for easy reference later:

```
$ docker run -d --rm --name groestlcoind Groestlcoin/groestlcoin
```

Once you have a Groestlcoin service running in the background, you can show running containers:

```
$ docker ps
```

Or view the logs of a service:

```
$ docker logs -f groestlcoind
```

To stop and restart a running container:

```
$ docker stop groestlcoind
$ docker start groestlcoind
```

### Alternative Clients

Images are also provided for btc1, Bitcoin Unlimited, Bitcoin Classic, and Bitcoin XT, which are separately maintained forks of the original Bitcoin Core codebase.

To run the latest version of btc1 Core:

```
$ docker run NicolasDorier/btc1
```

To run the latest version of Bitcoin Classic:

```
$ docker run NicolasDorier/bitcoinclassic
```

To run the latest version of Bitcoin Unlimited:

```
$ docker run NicolasDorier/bitcoinunlimited
```

To run the latest version of Bitcoin XT:

```
$ docker run NicolasDorier/bitcoinxt
```

Specific versions of these alternate clients may be run using the command line options above.

### Configuring Groestlcoin

The best method to configure the Groestlcoin server is to pass arguments to the `groestlcoind` command. For example, to run groestlcoin on the testnet:

```
$ docker run --name groestlcoind-testnet Groestlcoin/groestlcoin groestlcoind -testnet
```

Alternatively, you can edit the `groestlcoin.conf` file which is generated in your data directory (see below).

### Data Volumes

By default, Docker will create ephemeral containers. That is, the blockchain data will not be persisted, and you will need to sync the blockchain from scratch each time you launch a container.

To keep your blockchain data between container restarts or upgrades, simply add the `-v` option to create a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/):

```
$ docker run -d --rm --name groestlcoind -v groestlcoin-data:/data Groestlcoin/groestlcoin
$ docker ps
$ docker inspect groestlcoin-data
```

Alternatively, you can map the data volume to a location on your host:

```
$ docker run -d --rm --name groestlcoind -v "$PWD/data:/data" Groestlcoin/groestlcoin
$ ls -alh ./data
```

### Using groestlcoin-cli

By default, Docker runs all containers on a private bridge network. This means that you are unable to access the RPC port (1441) necessary to run `groestlcoin-cli` commands.

There are several methods to run `groestlcoin-cli` against a running `groestlcoind` container. The easiest is to simply let your `groestlcoin-cli` container share networking with your `groestlcoind` container:

```
$ docker run -d --rm --name groestlcoind -v groestlcoin-data:/data Groestlcoin/groestlcoin
$ docker run --rm --network container:groestlcoind Groestlcoin/groestlcoin groestlcoin-cli getinfo
```

If you plan on exposing the RPC port to multiple containers (for example, if you are developing an application which communicates with the RPC port directly), you probably want to consider creating a [user-defined network](https://docs.docker.com/engine/userguide/networking/). You can then use this network for both your `groestlcoind` and `groestlcoin-cli` containers, passing `-rpcconnect` to specify the hostname of your `groestlcoind` container:

```
$ docker network create groestlcoin
$ docker run -d --rm --name groestlcoind -v groestlcoin-data:/data --network groestlcoin Groestlcoin/groestlcoin
$ docker run --rm --network groestlcoin Groestlcoin/groestlcoin groestlcoin-cli -rpcconnect=groestlcoind getinfo
```

### Complete Example

For a complete example of running a Groestlcoin node using Docker Compose, see the [Docker Compose example](/example#readme).

### License

Configuration files and code in this repository are distributed under the [MIT license](/LICENSE).

### Contributing

All files are generated from templates in the root of this repository. Please do not edit any of the generated Dockerfiles directly.

* To add a new Groestlcoin version, update [versions.yml](/versions.yml), then run `make update`.
* To make a change to the Dockerfile which affects all current and historical Groestlcoin versions, edit [Dockerfile.erb](/Dockerfile.erb) then run `make update`.

If you would like to build and test containers for all versions (similar to what happens in CI), run `make`. If you would like to build and test all containers for a specific Groestlcoin fork, run `BRANCH=core make`.
