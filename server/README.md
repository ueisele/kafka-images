# Docker Image for Apache Kafka Broker and Controller

Docker image for running the [Open Source version of Apache Kafka](https://github.com/apache/kafka/).
It offers support for running Kafka [KRaft mode](https://github.com/apache/kafka/blob/3.1.0/config/kraft/README.md) as well as in ZooKeeper mode.

The Kafka distribution included in the Docker image is built directly from [source](https://github.com/apache/kafka/).

The Docker images are available on DockerHub repository [ueisele/apache-kafka-server](https://hub.docker.com/repository/docker/ueisele/apache-kafka-server), and the source files for the images are available on GitHub repository [ueisele/kafka-images](https://github.com/ueisele/kafka-images).

## Most Recent Tags

Most recent tags for `RELEASE` builds:

* `3.1.0`, `3.1.0-zulu17`, `3.1.0-zulu17.0.2`, `3.1.0-zulu17-ubi8.5`, `3.1.0-zulu17.0.2-ubi8.5-218`
* `3.0.0`, `3.0.0-zulu17`, `3.0.0-zulu17.0.2`, `3.0.0-zulu17-ubi8.5`, `3.0.0-zulu17.0.2-ubi8.5-218`
* `2.8.1`, `2.8.1-zulu11`, `2.8.1-zulu11.0.14`, `2.8.1-zulu11-ubi8.5`, `2.8.1-zulu11.0.14-ubi8.5-218`
* `2.8.0`, `2.8.0-zulu11`, `2.8.0-zulu11.0.14`, `2.8.0-zulu11-ubi8.5`, `2.8.0-zulu11.0.14-ubi8.5-218`

Most recent tags for `SNAPSHOT` builds:

* `3.2.0-SNAPSHOT`, `3.2.0-SNAPSHOT-zulu17`, `3.2.0-SNAPSHOT-zulu17.0.2`, `3.2.0-SNAPSHOT-zulu17-ubi8.5`, `3.2.0-SNAPSHOT-zulu17.0.2-ubi8.5-218`

Additionally, a tag with the associated Git-Sha of the built Apache Kafka distribution is always published as well, e.g. `ueisele/apache-kafka-server:3.2.0-SNAPSHOT-g7215c90`.

## Image

The Docker images are based on [ueisele/openjdk-jre](https://hub.docker.com/repository/docker/ueisele/openjdk-jre). 

The OpenJDK image in turn is based on [RedHat's Universal Base Image 8](https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/5c359a62bed8bd75a2c3fba8). If a new version of the base image is released, typically also a new version of this Docker image is created and published.

As OpenJDK [Azul Zulu](https://www.azul.com/downloads/?package=jdk) is used.
Azul Zulu builds of OpenJDK are fully tested and TCK compliant builds of OpenJDK.

## Quick Start

In the following section you find some simple examples to run Apache Kafka in `KRaft` mode as well as in `ZooKeeper` mode.

### KRaft Mode

Apache Kafka 2.8 is the first release wich contains `KRaft` as an operation mode which requires no ZooKeeper.
`KRaft` mode in Apache Kafka 2.8 and 3.0 is provided for testing only, NOT for production. 
It is not yet supported to upgrade existing ZooKeeper-based Kafka clusters into this mode. 
In fact, when Kafka 3.1 is released, it will not be possible to upgrade your `KRaft` clusters from 3.0 to 3.1. 
There may be bugs, including serious ones. You should assume that your data could be lost at any time if you try the early access release of `KRaft` mode.

In order to run Apache Kafka with a single instance in `KRaft` mode, run the following command:

```bash
docker run -d --name kafka-kraft -p 9092:9092 \
    -e AUTO_GENERATE_CLUSTER_ID=true \
    -e AUTO_FORMAT_KAFKA_STORAGE_DIR=true \
    -e KAFKA_PROCESS_ROLES=broker,controller \
    -e KAFKA_NODE_ID=1 \
    -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
    -e KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://127.0.0.1:9092 \
    -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
    -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
    ueisele/apache-kafka-server:3.0.0
```

You find additional examples in [examples/kraft/]():

* [examples/kraft/single-mode/docker-compose.yaml]()
* [examples/kraft/cluster-shared-mode/docker-compose.yaml]()
* [examples/kraft/cluster-dedicated-mode/docker-compose.yaml]()
* [examples/kraft/cluster-mixed-mode/docker-compose.yaml]()
* [examples/kraft/cluster-ssl-pem/docker-compose.yaml]()
* [examples/kraft/cluster-ssl-jks/docker-compose.yaml]()
* [examples/kraft/cluster-ssl-pkcs12/docker-compose.yaml]()

You find an introduction about `KRaft` mode at the Confluent Blog Post [Apache Kafka Made Simple: A First Glimpse of a Kafka Without ZooKeeper](https://www.confluent.io/blog/kafka-without-zookeeper-a-sneak-peek/).

### ZooKeeper Mode

In order to run Apache Kafka with a single instance in `ZooKeeper` mode, first start a single ZooKeeper instance:

```bash
docker run -d --name zookeeper --net host \
    -e ZOO_MY_ID=1 \
    -e ZOO_SERVERS="server.1=localhost:2888:3888;2181" \
    zookeeper:3.7.0
```

If ZooKeeper is running, a single Kafka instance can be started with the following command:

```bash
docker run -d --name kafka-zk --net host \
    -e KAFKA_NODE_ID=1 \
    -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181 \
    -e KAFKA_LISTENERS=PLAINTEXT://:9092 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
    ueisele/apache-kafka-server:3.1.0
```

You find additional examples in [examples/zk/]():

* [examples/zk/cluster/docker-compose.yaml]()

## Configuration

For the Apache Kafka ([ueisele/apache-kafka-server](https://hub.docker.com/repository/registry-1.docker.io/ueisele/apache-kafka-server/)) image, convert the [Apache Kafka broker configuration properties](https://kafka.apache.org/documentation/#brokerconfigs) as below and use them as environment variables:

* Prefix with KAFKA_.
* Convert to upper-case.
* Replace a period (.) with a single underscore (_).
* Replace a dash (-) with double underscores (__).
* Replace an underscore (_) with triple underscores (___).

The configuration is fully compatible with the [Confluent Docker images](https://docs.confluent.io/platform/current/installation/docker/config-reference.html#confluent-ak-configuration).

The configuration mechanism supports [`Go Template`](https://pkg.go.dev/text/template) for environment variable values.
The templating is done by [`godub`](https://github.com/ueisele/go-docker-utils) and therefore provides its [template functions](https://github.com/ueisele/go-docker-utils#template-functions). 

Example which uses `ipAddress` function to determin the IPv4 address of the first network interface:

```properties
KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://[{{ ipAddress \"prefer\" \"ipv4\" 0 }}]:{{ .PORT }}"
```

### Important Configuration in KRaft Mode

In the following section you find important configuration, required to operate Apache Kafka in `Kraft` mode. 
For a comprehensive overview of all configurations, see https://kafka.apache.org/documentation/.

#### Storage Initialization

In `Kraft` mode the [cluster storage must be initialized first](https://github.com/apache/kafka/blob/3.0.0/config/kraft/README.md#quickstart).

By default, the Docker image expects that the directories which are used for storage are already initialized. 

The initialization can also be done automatically, by setting `AUTO_FORMAT_KAFKA_STORAGE_DIR` to `true`.
If this is the case the storage directory is formatted if it is not already formatted.

The cluster storage must be initialized with a specific [cluster ID](https://github.com/apache/kafka/blob/3.0.0/config/kraft/README.md#generate-a-cluster-id), which mus be generated.
This can be either done:

* manually, by explicitly using `CLUSTER_ID`
* automatically, by setting `AUTO_GENERATE_CLUSTER_ID=true`

#### Role

`KAFKA_PROCESS_ROLES` defines in which mode the server runs and which roles it has. Valid values are 'broker', 'controller' 'broker,controller' and ''. If empty the server runs in ZooKeeper mode.

#### Node ID

`KAFKA_NODE_ID` sets the node id for this server. This configuration is required in KRaft mode.

#### Listeners

`KAFKA_LISTENERS` is defined as a list of URIs Kafka will listen on and the listener names. 
In KRaft mode, this are broker listeners as well as controller listeners. 
If for example `KAFKA_PROCESS_ROLES=broker,controller` you must specify listeners for both, for example `PLAINTEXT://:9092,CONTROLLER://:9093`

`KAFKA_ADVERTISED_LISTENERS` describes how the host name that is advertised can be reached by clients. 
Advertised listeners must only be specified for broker listeners and not for controller listeners.
For example, if you have defined one listener for broker and one for controller with `KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093`, you must specify an advertised listener only for `PLAINTEXT`, e.g. `KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092`.

If you specify a listener name which is not equal to a security protocol, like `CONTROLLER`, 
`KAFKA_LISTENER_SECURITY_PROTOCOL_MAP` must also be set. It is a map between listener names and security protocols.
For example if `KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093` and you want to use `PLAINTEXT` security protocol also for the controller you must set `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT`.

#### Controller

`KAFKA_CONTROLLER_QUORUM_VOTERS` sets the the connect string for the controller quorum. This configuration is required in KRaft mode.
It is a map of id/endpoint information for the set of voters in a comma-separated list of `{id}@{host}:{port}` entries. For example: `1@localhost:9092,2@localhost:9093,3@localhost:9094` 

`KAFKA_CONTROLLER_LISTENER_NAMES` is the comma-separated list of the names of the listeners used by the controller. This configuration is required in KRaft mode.
In broker role, you only need to configure the security protocol which is used by the controller.
In controller role, you need to specify the list of listeners used by the controller.
For example, if `KAFKA_PROCESS_ROLES=broker,controller` and `KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093` you must set `KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER`.

### Important Configuration in ZooKeeper Mode

In the following section you find important configuration, required to operate Apache Kafka in `ZooKeeper` mode. 
For a comprehensive overview of all configurations, see https://kafka.apache.org/documentation/.

#### Node ID

`KAFKA_NODE_ID` sets the node id for this server. This configuration is optional in ZooKeeper mode.

#### ZooKeeper

`KAFKA_ZOOKEEPER_CONNECT` specifies the ZooKeeper connection string in the form hostname:port where host and port are the host and port of a ZooKeeper server. To allow connecting through other ZooKeeper nodes when that ZooKeeper machine is down you can also specify multiple hosts in the form hostname1:port1,hostname2:port2,hostname3:port3.
This configuration is required on ZooKeeper mode.

#### Listeners

`KAFKA_ADVERTISED_LISTENERS` describes how the host name that is advertised can be reached by clients. 
This configuration is required in ZooKeeper mode.
For example `KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092`.

The actual listeners are derived by the listeners configured at `KAFKA_ADVERTISED_LISTENERS`.
For example if `KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092`, the Docker container will automatically set
`KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092`.

However, you can also explicitly specify `KAFKA_LISTENERS` to define where Kafka will listen on.
`KAFKA_LISTENERS` is defined as a list of URIs Kafka will listen on and the listener names. 
For example `KAFKA_LISTENERS=PLAINTEXT://127.0.0.1:9092`

If you specify a listener name which is not equal to a security protocol, like `CONTROLLER`, 
`KAFKA_LISTENER_SECURITY_PROTOCOL_MAP` must also be set. It is a map between listener names and security protocols.

### Storage

By default `KAFKA_LOG_DIRS` is set to `/opt/apache/kafka/data`.

In order to make the storage independent of the Docker container, you can explicitly create an volume:

```bash
docker volume create kafka-data
docker run -d --name kafka-kraft -p 9092:9092 \
    -v kafka-data:/opt/apache/kafka/data \
    -e AUTO_GENERATE_CLUSTER_ID=true \
    -e AUTO_FORMAT_KAFKA_STORAGE_DIR=true \
    -e KAFKA_PROCESS_ROLES=broker,controller \
    -e KAFKA_NODE_ID=1 \
    -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
    -e KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://127.0.0.1:9092 \
    -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
    -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
    ueisele/apache-kafka-server:3.1.0
```

## Build

In order to create your own Docker image for Apache Kafka clone the [ueisele/kafka-image](https://github.com/ueisele/kafka-images) Git repository and run the build command:

```bash
git clone https://github.com/ueisele/kafka-images.git
cd kafka-images
server/build.sh --build --tag 3.1.0 --openjdk-release 17
```

To create an image with a specific OpenJDK version use the following command:

```bash
server/build.sh --build --tag 3.1.0 --openjdk-release 17 --openjdk-version 17.0.2
```

By default Apache Kafka 3.0.0 does not support Java 17. In order to build Apache Kafka 3.0.0 with Java 17, the Gradle configuration is patched with [patch/3.0.0-openjdk17.patch]().

```bash
server/build.sh --build --tag 3.0.0 --openjdk-release 17 --patch 3.0.0-openjdk17.patch
```

To build the most recent `SNAPSHOT` of Apache Kafka 3.2.0 with Java 17, run:

```bash
server/build.sh --build --branch trunk --openjdk-release 17
```

### Build Options

The `server/build.sh` script provides the following options:

`Usage: server/build.sh [--build] [--push] [--user ueisele] [--github-repo apache/kafka] [ [--commit-sha 37edeed] [--tag 3.1.0] [--branch trunk] [--pull-request 9999] ] [--openjdk-release 17] [--openjdk-version 17.0.2] [--patch 3.0.0-openjdk17.patch]`

## License 

This Docker image is licensed under the [Apache 2 license](https://github.com/ueisele/kafka-images/blob/main/LICENSE).