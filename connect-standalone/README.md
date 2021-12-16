# Docker Image for Apache Kafka Connect Standalone

Docker image for running the [Open Source version of Apache Kafka Connect](https://github.com/apache/kafka/) in standalone mode.

The Kafka distribution included in the Docker image is built directly from [source](https://github.com/apache/kafka/).

The Docker images are available on DockerHub repository [ueisele/apache-kafka-connect-standalone](https://hub.docker.com/repository/docker/ueisele/apache-kafka-connect-standalone), and the source files for the images are available on GitHub repository [ueisele/kafka-images](https://github.com/ueisele/kafka-images).

## Most Recent Tags

Most recent tags for `RELEASE` builds:

* `3.0.0`, `3.0.0-zulu17`, `3.0.0-zulu17.0.1`, `3.0.0-zulu17-ubi8.5`, `3.0.0-zulu17.0.1-ubi8.5-204`
* `2.8.1`, `2.8.1-zulu11`, `2.8.1-zulu11.0.13`, `2.8.1-zulu11-ubi8.5`, `2.8.1-zulu11.0.13-ubi8.5-204`
* `2.8.0`, `2.8.0-zulu11`, `2.8.0-zulu11.0.13`, `2.8.0-zulu11-ubi8.5`, `2.8.0-zulu11.0.13-ubi8.5-204`

Most recent tags for `SNAPSHOT` builds:

* `3.2.0-SNAPSHOT`, `3.2.0-SNAPSHOT-zulu17`, `3.2.0-SNAPSHOT-zulu17.0.1`, `3.2.0-SNAPSHOT-zulu17-ubi8.5`, `3.2.0-SNAPSHOT-zulu17.0.1-ubi8.5-204`
* `3.1.0-SNAPSHOT`, `3.1.0-SNAPSHOT-zulu17`, `3.1.0-SNAPSHOT-zulu17.0.1`, `3.1.0-SNAPSHOT-zulu17-ubi8.5`, `3.1.0-SNAPSHOT-zulu17.0.1-ubi8.5-204`

Additionally, a tag with the associated Git-Sha of the built Apache Kafka distribution is always published as well, e.g. `ueisele/apache-kafka-connect:3.1.0-SNAPSHOT-g36cc3dc`.

## Image

The standalone Docker image is based on [ueisele/apache-kafka-connect](https://hub.docker.com/repository/docker/ueisele/apache-kafka-connect). 

## Quick Start

In the following section you find some simple examples to run Apache Kafka Connect.

First create a Docker network:
```bash
docker network create quickstart-kafka-connect-standalone
```

Now, start a single Kafka instance: 

```bash
docker run -d --name kafka --net quickstart-kafka-connect-standalone -p 9092:9092 ueisele/apache-kafka-server-standalone:3.0.0
```

Create some sample data:

```bash
for i in {1..7}; do echo "log line $i"; done > source.txt
```

In order to run Apache Kafka Connect in standalone mode run the following command:

```bash
docker run -d --name kafka-connect-standalone \
    --net quickstart-kafka-connect-standalone -p 8083:8083 \
    -v "$(pwd)/source.txt:/var/lib/kafka-connect/source.txt" \
    -e CONNECT_BOOTSTRAP_SERVERS=kafka:9092 \
    -e CONNECT_KEY_CONVERTER=org.apache.kafka.connect.storage.StringConverter \
    -e CONNECT_VALUE_CONVERTER=org.apache.kafka.connect.storage.StringConverter \
    -e CONNECT_OFFSET_FLUSH_INTERVAL_MS=5000 \
    -e CONNECTOR_NAME=file-source \
    -e CONNECTOR_CONNECTOR_CLASS=FileStreamSource \
    -e CONNECTOR_TASKS_MAX=1 \
    -e CONNECTOR_FILE=/var/lib/kafka-connect/source.txt \
    -e CONNECTOR_TOPIC=connect-file-source \
    ueisele/apache-kafka-connect-standalone:3.0.0
```

Consume published messages:

```bash
docker run --rm -it --net quickstart-kafka-connect-standalone ueisele/apache-kafka-server-standalone:3.0.0 \
    kafka-console-consumer.sh \
        --bootstrap-server kafka:9092 \
        --topic connect-file-source \
        --from-beginning
```

If you add additional lines to the sample data you will recognise that it is published, too:

```bash
for i in {1..3}; do echo "additional log line $i"; done >> source.txt
```

You find additional examples in [examples/connect-standalone/]():

* [examples/connect-standalone/file-source/docker-compose.yaml]()
* [examples/connect-standalone/datagen-plugin-install/docker-compose.yaml]()

## Configuration

For the Apache Kafka Connect ([ueisele/apache-kafka-connect-standalone](https://hub.docker.com/repository/registry-1.docker.io/ueisele/apache-kafka-connect/)) image, convert the [Apache Kafka Connect configuration properties](https://kafka.apache.org/documentation/#connectconfigs) as below and use them as environment variables:

* Prefix with CONNECT_.
* Convert to upper-case.
* Replace a period (.) with a single underscore (_).
* Replace a dash (-) with double underscores (__).
* Replace an underscore (_) with triple underscores (___).

The configuration is fully compatible with the [Confluent Docker images](https://docs.confluent.io/platform/current/installation/docker/config-reference.html#kconnect-long-configuration).

The configuration mechanism supports [`Go Template`](https://pkg.go.dev/text/template) for environment variable values.
The templating is done by [`godub`](https://github.com/ueisele/go-docker-utils) and therefore provides its [template functions](https://github.com/ueisele/go-docker-utils#template-functions). 

### Required Worker Configuration

The minimum required worker configuration is `CONNECT_BOOTSTRAP_SERVERS` which defines the the Kafka bootstrap servers
and `CONNECT_KEY_CONVERTER` and `CONNECT_VALUE_CONVERTER` which define the converters used for key and value.

```yaml
CONNECT_BOOTSTRAP_SERVERS: kafka:9092
CONNECT_KEY_CONVERTER: org.apache.kafka.connect.storage.StringConverter
CONNECT_VALUE_CONVERTER: org.apache.kafka.connect.storage.StringConverter
```

### Required Connector Configuration

The minimum required configuration for a connector is `CONNECTOR_NAME` which defines the connector instance name
and `CONNECTOR_CONNECTOR_CLASS` which defines the class implementing the connector. 

```yaml
CONNECTOR_NAME: file-source
CONNECTOR_CONNECTOR_CLASS: FileStreamSource
```

### Offset Storage

Kafka Connect standalone does maintain its offsets in a file. This file is by default located at `/opt/apache/kafka/data/connect.offsets`
You can change the file name by setting the following configuration.

```yaml
CONNECT_STANDALONE_OFFSET_STORAGE_FILE_FILENAME: file-source.offsets
```

In order to save the offset, you should always bind the `/opt/apache/kafka/data/` directory as dedicated volume.

You can also specify the flush interval for the offsets. By default its one minute.

```yaml
CONNECT_OFFSET_FLUSH_INTERVAL_MS: 5000
```

### Connector Installation

The Apache Kafka Connect Docker image supports Connector installation during startup with multiple methods.

Define a comma separated list of Confluent Hub Connectors to be installed.

```yaml
CONNECT_PLUGIN_INSTALL_CONFLUENT_HUB_CONNECTOR_IDS: confluentinc/kafka-connect-jdbc:latest,confluentinc/kafka-connect-http:latest
```

Define a comma separated list of Connector Urls. Supported are `*.zip`, `*.tar`, `*.tgz` and `*.jar` files.

```yaml
CONNECT_PLUGIN_INSTALL_EXTENSION_URLS: |
    https://github.com/castorm/kafka-connect-http/releases/download/v0.8.11/castorm-kafka-connect-http-0.8.11.zip
    https://github.com/RedHatInsights/expandjsonsmt/releases/download/0.0.7/kafka-connect-smt-expandjsonsmt-0.0.7.tar.gz
```

Specify a bash command to download a file to a specific directory, for example to install a JDBC driver for the JDBC connector.

```yaml
CONNECT_PLUGIN_INSTALL_CMDS: |
    wget -qP $${CONNECT_PLUGIN_INSTALL_DIR}/confluentinc-kafka-connect-jdbc/lib https://dlm.mariadb.com/1496775/Connectors/java/connector-java-2.7.2/mariadb-java-client-2.7.2.jar
```

## Build

In order to create your own Docker image for Apache Kafka Connect standalone clone the [ueisele/kafka-image](https://github.com/ueisele/kafka-images) Git repository and run the build command:

```bash
git clone https://github.com/ueisele/kafka-images.git
cd kafka-images
connect-standalone/build.sh --build --tag 3.0.0 --openjdk-release 17
```

To create an image with a specific OpenJDK version use the following command:

```bash
connect-standalone/build.sh --build --tag 3.0.0 --openjdk-release 17 --openjdk-version 17
```

To build the most recent `SNAPSHOT` of Apache Kafka 3.1.0 with Java 17, run:

```bash
connect-standalone/build.sh --build --branch trunk --openjdk-release 17
```

### Build Options

The `connect-standalone/build.sh` script provides the following options:

`Usage: connect-standalone/build.sh [--build] [--push] [--user ueisele] [--github-repo apache/kafka] [ [--commit-sha 8cb0a5e] [--tag 3.0.0] [--branch trunk] [--pull-request 9999] ] [--openjdk-release 17] [--openjdk-version 17]`
## License 

This Docker image is licensed under the [Apache 2 license](https://github.com/ueisele/kafka-images/blob/main/LICENSE).