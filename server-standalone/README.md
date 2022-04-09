# Standalone Docker Image for Apache Kafka Broker and Controller

Docker image for running the [Open Source version of Apache Kafka](https://github.com/apache/kafka/).
It offers support for running a single Apache Kafka instance in Kafka [KRaft mode](https://github.com/apache/kafka/blob/3.1.0/config/kraft/README.md).

The Kafka distribution included in the Docker image is built directly from [source](https://github.com/apache/kafka/).

The standalone Docker image is based on [ueisele/apache-kafka-server](https://hub.docker.com/repository/docker/ueisele/apache-kafka-server). 

The Docker images are available on DockerHub repository [ueisele/apache-kafka-server-standalone](https://hub.docker.com/repository/docker/ueisele/apache-kafka-server), and the source files for the images are available on GitHub repository [ueisele/kafka-images](https://github.com/ueisele/kafka-images).

## Most Recent Tags

Most recent tags for `RELEASE` builds:

* `3.1.0`, `3.1.0-zulu17`, `3.1.0-zulu17.0.2`, `3.1.0-zulu17-ubi8.5`, `3.1.0-zulu17.0.2-ubi8.5-240`
* `3.0.1`, `3.0.1-zulu17`, `3.0.1-zulu17.0.2`, `3.0.1-zulu17-ubi8.5`, `3.0.1-zulu17.0.2-ubi8.5-240`
* `3.0.0`, `3.0.0-zulu17`, `3.0.0-zulu17.0.2`, `3.0.0-zulu17-ubi8.5`, `3.0.0-zulu17.0.2-ubi8.5-240`
* `2.8.1`, `2.8.1-zulu11`, `2.8.1-zulu11.0.14`, `2.8.1-zulu11-ubi8.5`, `2.8.1-zulu11.0.14-ubi8.5-240`
* `2.8.0`, `2.8.0-zulu11`, `2.8.0-zulu11.0.14`, `2.8.0-zulu11-ubi8.5`, `2.8.0-zulu11.0.14-ubi8.5-240`

Most recent tags for `SNAPSHOT` builds:

* `3.3.0-SNAPSHOT`, `3.3.0-SNAPSHOT-zulu17`, `3.3.0-SNAPSHOT-zulu17.0.2`, `3.3.0-SNAPSHOT-zulu17-ubi8.5`, `3.3.0-SNAPSHOT-zulu17.0.2-ubi8.5-240`
* `3.2.0-SNAPSHOT`, `3.2.0-SNAPSHOT-zulu17`, `3.2.0-SNAPSHOT-zulu17.0.2`, `3.2.0-SNAPSHOT-zulu17-ubi8.5`, `3.2.0-SNAPSHOT-zulu17.0.2-ubi8.5-240`

Additionally, a tag with the associated Git-Sha of the built Apache Kafka distribution is always published as well, e.g. `ueisele/apache-kafka-server-standalome:3.2.0-SNAPSHOT-g7215c90`.

## Quick Start

To start a single Kafka instance in KRaft mode just run: 

```bash
docker run --rm -p 9092:9092 ueisele/apache-kafka-server-standalone:3.1.0
```

To start a single Kafka instance in KRaft mode with Ipv6 just run: 

```bash
docker network create --ipv6 --subnet fd01::/80 kafka-standalone
docker run --rm -p 9092:9092 --net kafka-standalone -e STANDALONE_BROKER_IP_VERSION=ipv6 ueisele/apache-kafka-server-standalone:3.1.0
```

## Configuration

The [ueisele/apache-kafka-server-standalone](https://hub.docker.com/repository/registry-1.docker.io/ueisele/apache-kafka-server/) image just sets environment variables which are required for a standalone execution (see [Dockerfile](server-standalone/Dockerfile.ubi8)). 

The configuration is identical to the [ueisele/apache-kafka-server](https://hub.docker.com/repository/docker/ueisele/apache-kafka-server) image and therefore also fully compatible with the [Confluent Docker images](https://docs.confluent.io/platform/current/installation/docker/config-reference.html#confluent-ak-configuration).

For the Apache Kafka ([ueisele/apache-kafka-server-standalone](https://hub.docker.com/repository/registry-1.docker.io/ueisele/apache-kafka-server/)) image, convert the [Apache Kafka broker configuration properties](https://kafka.apache.org/documentation/#brokerconfigs) as below and use them as environment variables:

* Prefix with KAFKA_.
* Convert to upper-case.
* Replace a period (.) with a single underscore (_).
* Replace a dash (-) with double underscores (__).
* Replace an underscore (_) with triple underscores (___).

### Listeners

By default the standalone Kafka opens a listener on port 9092 on all interfaces and advertises the first found Ip address.

However, you can overwrite the advertised listener and the listener of the broker with `STANDALONE_BROKER_LISTENERS` and `STANDALONE_BROKER_ADVERTISED_LISTENERS`.
For example `STANDALONE_BROKER_LISTENERS=PLAINTEXT://127.0.0.1:9092` and `STANDALONE_BROKER_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092`.

The security protocol map for the broker can be set with `STANDALONE_BROKER_LISTENER_SECURITY_PROTOCOL_MAP`.

If you only want to change the port of the broker, you can set `STANDALONE_BROKER_PORT`.

In addition to the `STANDALONE_BROKER_` variables, you can also directly specify `KAFKA_` variables.
`STANDALONE_BROKER_` variables are just a convenient way to configure the standalone Kafka instance without the need to also set the controller configuration. 

## Build

In order to create your own Docker image for Apache Kafka clone the [ueisele/kafka-image](https://github.com/ueisele/kafka-images) Git repository and run the build command:

```bash
git clone https://github.com/ueisele/kafka-images.git
cd kafka-images
server-standalone/build.sh --build --tag 3.1.0 --openjdk-release 17
```

To create an image with a specific OpenJDK version use the following command:

```bash
server-standalone/build.sh --build --tag 3.1.0 --openjdk-release 17 --openjdk-version 17.0.2
```

To build the most recent `SNAPSHOT` of Apache Kafka 3.2.0 with Java 17, run:

```bash
server-standalone/build.sh --build --branch trunk --openjdk-release 17
```

### Build Options

The `server-standalone/build.sh` script provides the following options:

`Usage: server-standalone/build.sh [--build] [--push] [--user ueisele] [--github-repo apache/kafka] [ [--commit-sha 37edeed] [--tag 3.1.0] [--branch trunk] [--pull-request 9999] ] [--openjdk-release 17] [--openjdk-version 17.0.2]`

## License 

This Docker image is licensed under the [Apache 2 license](https://github.com/ueisele/kafka-images/blob/main/LICENSE).