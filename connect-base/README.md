# Docker Image for Apache Kafka Connect (Base)

Docker image for running the [Open Source version of Apache Kafka Connect](https://github.com/apache/kafka/) in distributed mode.

The Kafka distribution included in the Docker image is built directly from [source](https://github.com/apache/kafka/).
It is a base image and therefore has no additional Cli tools and Kafka Connect plugins installed.

The Docker images are available on DockerHub repository [ueisele/apache-kafka-connect-base](https://hub.docker.com/repository/docker/ueisele/apache-kafka-connect-base), and the source files for the images are available on GitHub repository [ueisele/kafka-images](https://github.com/ueisele/kafka-images).

## Most Recent Tags

Most recent tags for `RELEASE` builds:

* `3.3.1`, `3.3.1-zulu17`, `3.3.1-zulu17.0.5`, `3.3.1-zulu17-ubi8.7`, `3.3.1-zulu17.0.5-ubi8.7-1031`
* `3.3.0`, `3.3.0-zulu17`, `3.3.0-zulu17.0.5`, `3.3.0-zulu17-ubi8.7`, `3.3.0-zulu17.0.5-ubi8.7-1031`
* `3.2.3`, `3.2.3-zulu17`, `3.2.3-zulu17.0.5`, `3.2.3-zulu17-ubi8.7`, `3.2.3-zulu17.0.5-ubi8.7-1031`
* `3.2.2`, `3.2.2-zulu17`, `3.2.2-zulu17.0.5`, `3.2.2-zulu17-ubi8.7`, `3.2.2-zulu17.0.5-ubi8.7-1031`
* `3.2.1`, `3.2.1-zulu17`, `3.2.1-zulu17.0.5`, `3.2.1-zulu17-ubi8.7`, `3.2.1-zulu17.0.5-ubi8.7-1031`
* `3.2.0`, `3.2.0-zulu17`, `3.2.0-zulu17.0.5`, `3.2.0-zulu17-ubi8.7`, `3.2.0-zulu17.0.5-ubi8.7-1031`
* `3.1.2`, `3.1.2-zulu17`, `3.1.2-zulu17.0.5`, `3.1.2-zulu17-ubi8.7`, `3.1.2-zulu17.0.5-ubi8.7-1031`
* `3.1.1`, `3.1.1-zulu17`, `3.1.1-zulu17.0.5`, `3.1.1-zulu17-ubi8.7`, `3.1.1-zulu17.0.5-ubi8.7-1031`
* `3.1.0`, `3.1.0-zulu17`, `3.1.0-zulu17.0.5`, `3.1.0-zulu17-ubi8.7`, `3.1.0-zulu17.0.5-ubi8.7-1031`
* `3.0.2`, `3.0.2-zulu17`, `3.0.2-zulu17.0.5`, `3.0.2-zulu17-ubi8.7`, `3.0.2-zulu17.0.5-ubi8.7-1031`
* `3.0.1`, `3.0.1-zulu17`, `3.0.1-zulu17.0.5`, `3.0.1-zulu17-ubi8.7`, `3.0.1-zulu17.0.5-ubi8.7-1031`
* `3.0.0`, `3.0.0-zulu17`, `3.0.0-zulu17.0.5`, `3.0.0-zulu17-ubi8.7`, `3.0.0-zulu17.0.5-ubi8.7-1031`
* `2.8.2`, `2.8.2-zulu11`, `2.8.2-zulu11.0.17`, `2.8.2-zulu11-ubi8.7`, `2.8.2-zulu11.0.17-ubi8.7-1031`
* `2.8.1`, `2.8.1-zulu11`, `2.8.1-zulu11.0.17`, `2.8.1-zulu11-ubi8.7`, `2.8.1-zulu11.0.17-ubi8.7-1031`
* `2.8.0`, `2.8.0-zulu11`, `2.8.0-zulu11.0.17`, `2.8.0-zulu11-ubi8.7`, `2.8.0-zulu11.0.17-ubi8.7-1031`

Most recent tags for `SNAPSHOT` builds:

* `3.5.0-SNAPSHOT`, `3.5.0-SNAPSHOT-zulu17`, `3.5.0-SNAPSHOT-zulu17.0.5`, `3.5.0-SNAPSHOT-zulu17-ubi8.7`, `3.5.0-SNAPSHOT-zulu17.0.5-ubi8.7-1031`
* `3.4.0-SNAPSHOT`, `3.4.0-SNAPSHOT-zulu17`, `3.4.0-SNAPSHOT-zulu17.0.5`, `3.4.0-SNAPSHOT-zulu17-ubi8.7`, `3.4.0-SNAPSHOT-zulu17.0.5-ubi8.7-1031`

Additionally, a tag with the associated Git-Sha of the built Apache Kafka distribution is always published as well, e.g. `ueisele/apache-kafka-server-standalome:3.3.0-SNAPSHOT-g478de45`.

## Image

The Docker images are based on [ueisele/openjdk-jre](https://hub.docker.com/repository/docker/ueisele/openjdk-jre). 

The OpenJDK image in turn is based on [RedHat's Universal Base Image 8](https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/5c359a62bed8bd75a2c3fba8). If a new version of the base image is released, typically also a new version of this Docker image is created and published.

As OpenJDK [Azul Zulu](https://www.azul.com/downloads/?package=jdk) is used.
Azul Zulu builds of OpenJDK are fully tested and TCK compliant builds of OpenJDK.

## Quick Start

In the following section you find some simple examples to run Apache Kafka Connect.

First create a Docker network:
```bash
docker network create quickstart-kafka-connect
```

Now, start a single Kafka instance: 

```bash
docker run -d --name kafka --net quickstart-kafka-connect -p 9092:9092 ueisele/apache-kafka-server-standalone:3.1.0
```

In order to run Apache Kafka Connect with a single instance run the following command:

```bash
docker run -d --name kafka-connect --net quickstart-kafka-connect -p 8083:8083 \
    -e CONNECT_BOOTSTRAP_SERVERS=kafka:9092 \
    -e CONNECT_REST_ADVERTISED_HOST_NAME=localhost \
    -e CONNECT_REST_PORT=8083 \
    -e CONNECT_GROUP_ID=quickstart-kafka-connect \
    -e CONNECT_CONFIG_STORAGE_TOPIC=quickstart-kafka-connect-config \
    -e CONNECT_OFFSET_STORAGE_TOPIC=quickstart-kafka-connect-offsets \
    -e CONNECT_STATUS_STORAGE_TOPIC=quickstart-kafka-connect-status \
    -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 \
    -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 \
    -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 \
    -e CONNECT_KEY_CONVERTER=org.apache.kafka.connect.json.JsonConverter \
    -e CONNECT_VALUE_CONVERTER=org.apache.kafka.connect.json.JsonConverter \
    -e CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE=false \
    -e CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE=true \
    -e CONNECT_LOG4J_LOGGERS: org.reflections=ERROR,org.apache.zookeeper=ERROR,org.I0Itec.zkclient=ERROR \
    ueisele/apache-kafka-connect-base:3.2.1
```

You find additional examples in [examples/connect-standalone/]():

* [examples/connect-standalone/file-source/docker-compose.yaml]()
* [examples/connect-standalone/http-source-plugin-install/docker-compose.yaml]()

## Configuration

For the Apache Kafka Connect ([ueisele/apache-kafka-connect-base](https://hub.docker.com/repository/registry-1.docker.io/ueisele/apache-kafka-connect-base/)) image, convert the [Apache Kafka Connect configuration properties](https://kafka.apache.org/documentation/#connectconfigs) as below and use them as environment variables:

* Prefix with CONNECT_.
* Convert to upper-case.
* Replace a period (.) with a single underscore (_).
* Replace a dash (-) with double underscores (__).
* Replace an underscore (_) with triple underscores (___).

The configuration is fully compatible with the [Confluent Docker images](https://docs.confluent.io/platform/current/installation/docker/config-reference.html#kconnect-long-configuration).

The configuration mechanism supports [`Go Template`](https://pkg.go.dev/text/template) for environment variable values.
The templating is done by [`godub`](https://github.com/ueisele/go-docker-utils) and therefore provides its [template functions](https://github.com/ueisele/go-docker-utils#template-functions). 

Example which uses `ipAddress` function to determin the IPv4 address of the first network interface:

```properties
CONNECT_REST_ADVERTISED_HOST_NAME="{{ ipAddress \"prefer\" \"ipv4\" 0 }}"
```
### Required Configuration

The minimum required worker configuration is:

* `CONNECT_BOOTSTRAP_SERVERS` which defines the the Kafka bootstrap servers
* `CONNECT_KEY_CONVERTER` and `CONNECT_VALUE_CONVERTER` which define the converters used for key and value.
* `CONNECT_GROUP_ID` which identifies the Connect cluster group this Worker belongs to.
* `CONNECT_CONFIG_STORAGE_TOPIC`, `CONNECT_OFFSET_STORAGE_TOPIC` and `CONNECT_STATUS_STORAGE_TOPIC` which define the names of the topics where connector tasks, configuration, offsets and status updates are stored. This names must be unique per Connect cluster.
* `CONNECT_REST_ADVERTISED_HOST_NAME` which defines the hostname that will be given out to other Workers to connect to. You should set this to a value that is resolvable by all containers.

### Kafka Connect Plugin Installation

The Apache Kafka Connect Docker image supports installation of Kafka Connect plugins like connectors during startup with multiple methods.

Define a comma separated list of plugin Urls. Supported are `*.zip`, `*.tar*`, `*.tgz` and `*.jar` files.

```yaml
PLUGIN_INSTALL_URLS: |
    https://github.com/castorm/kafka-connect-http/releases/download/v0.8.11/castorm-kafka-connect-http-0.8.11.zip
    https://github.com/RedHatInsights/expandjsonsmt/releases/download/0.0.7/kafka-connect-smt-expandjsonsmt-0.0.7.tar.gz
```

Define a comma separated list of 'path=url' pairs, to download additional libraries. Supported are `*.zip`, `*.tar*`, `*.tgz` and `*.jar` files.

```yaml
PLUGIN_INSTALL_LIB_URLS: |
    confluentinc-kafka-connect-jdbc/lib=https://dlm.mariadb.com/1496775/Connectors/java/connector-java-2.7.2/mariadb-java-client-2.7.2.jar
    confluentinc-kafka-connect-avro-converter/lib=https://repo1.maven.org/maven2/com/google/guava/guava/30.1.1-jre/guava-30.1.1-jre.jar
```

## Build

In order to create your own Docker image for Apache Kafka Connect clone the [ueisele/kafka-image](https://github.com/ueisele/kafka-images) Git repository and run the build command:

```bash
git clone https://github.com/ueisele/kafka-images.git
cd kafka-images
connect-base/build.sh --build --tag 3.3.1 --openjdk-release 17
```

To create an image with a specific OpenJDK version use the following command:

```bash
connect-base/build.sh --build --tag 3.3.1 --openjdk-release 17 --openjdk-version 17.0.5
```

By default Apache Kafka 3.0.0 does not support Java 17. In order to build Apache Kafka 3.0.0 with Java 17, the Gradle configuration is patched with [patch/3.0.0-openjdk17.patch]().

```bash
connect-base/build.sh --build --tag 3.0.0 --openjdk-release 17 --patch 3.0.0-openjdk17.patch
```

To build the most recent `SNAPSHOT` of Apache Kafka 3.4.0 with Java 17, run:

```bash
connect-base/build.sh --build --branch trunk --openjdk-release 17
```

### Build Options

The `connect-base/build.sh` script provides the following options:

`Usage: connect-base/build.sh [--build] [--push] [--user ueisele] [--github-repo apache/kafka] [ [--commit-sha b172a0a] [--tag 3.3.1] [--branch trunk] [--pull-request 9999] ] [--openjdk-release 17] [--openjdk-version 17.0.5] [--patch 3.0.0-openjdk17.patch]`

## License 

This Docker image is licensed under the [Apache 2 license](https://github.com/ueisele/kafka-images/blob/main/LICENSE).