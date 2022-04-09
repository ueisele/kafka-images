# Docker Image for Apache Kafka Connect Standalone

Docker image for running the [Open Source version of Apache Kafka Connect](https://github.com/apache/kafka/) in standalone mode.

The Kafka distribution included in the Docker image is built directly from [source](https://github.com/apache/kafka/).

The standalone Docker image is based on [ueisele/apache-kafka-connect](https://hub.docker.com/repository/docker/ueisele/apache-kafka-connect). 

The Docker images are available on DockerHub repository [ueisele/apache-kafka-connect-standalone](https://hub.docker.com/repository/docker/ueisele/apache-kafka-connect-standalone), and the source files for the images are available on GitHub repository [ueisele/kafka-images](https://github.com/ueisele/kafka-images).

**IMPORTANT**: Kafka Connect Standalone is not suited for most productive uses cases. It does not support scaling and offsets of external systems are just stored on a file. See also: https://rmoff.net/2019/11/22/common-mistakes-made-when-configuring-multiple-kafka-connect-workers/

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

Additionally, a tag with the associated Git-Sha of the built Apache Kafka distribution is always published as well, e.g. `ueisele/apache-kafka-connect-standalone:3.1.0-SNAPSHOT-g7215c90`.

## Quick Start

In the following section you find some simple examples to run Apache Kafka Connect.

First create a Docker network:
```bash
docker network create quickstart-kafka-connect-standalone
```

Now, start a single Kafka instance: 

```bash
docker run -d --name kafka --net quickstart-kafka-connect-standalone -p 9092:9092 ueisele/apache-kafka-server-standalone:3.1.0
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
    ueisele/apache-kafka-connect-standalone:3.1.0
```

Consume published messages:

```bash
docker run --rm -it --net quickstart-kafka-connect-standalone ueisele/apache-kafka-server-standalone:3.1.0 \
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
* [examples/connect-standalone/http-source-plugin-install/docker-compose.yaml]()

## Configuration

For the Apache Kafka Connect ([ueisele/apache-kafka-connect-standalone](https://hub.docker.com/repository/registry-1.docker.io/ueisele/apache-kafka-connect/)) image, convert the [Apache Kafka Connect configuration properties](https://kafka.apache.org/documentation/#connectconfigs) as below and use them as environment variables:

* Prefix with CONNECT_ for worker configuration.
* Prefix with CONNECTOR_ for connector configuration.
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

### Kafka Connect Plugin Installation

The Apache Kafka Connect Docker image supports installation of Kafka Connect plugins like connectors during startup with multiple methods.

Define a comma separated list of plugins which should be installed via Confluent Hub.

```yaml
PLUGIN_INSTALL_CONFLUENT_HUB_IDS: |
    confluentinc/kafka-connect-jdbc:latest
    confluentinc/kafka-connect-http:latest
```

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

### Verbatim Connector Configuration

Some configurations cannot be converted to the environment variable key/value schema. This is the case for example, if camel-case has been used for configuration variables, e.g. `transforms.expandvalue.sourceFields=value`.

To support configurations like this, you can define environment variable with `CONNECTORPROPERTIES_` as name prefix.
Any content is added to the connector configuration as is.

The following shows an example for a SMT configuration.

```yaml
CONNECTORPROPERTIES_TRANSFORMS: |
    transforms.expandvalue.type=com.redhat.insights.expandjsonsmt.ExpandJSON$$Value
    transforms.expandvalue.sourceFields=value
```

You can find the entire example setup at [examples/connect-standalone/http-source-plugin-install/docker-compose.yaml]().

## Pre-installed Kafka Connect Plugins

This Kafka Connect image has the Confluent converters for Avro, Protobuf and JSON Schema already pre-installed to simplify usage of Confluent Schema Registry.

* [confluentinc/kafka-connect-avro-converter:7.1.0](https://www.confluent.io/hub/confluentinc/kafka-connect-avro-converter)
* [confluentinc/kafka-connect-protobuf-converter:7.1.0](https://www.confluent.io/hub/confluentinc/kafka-connect-protobuf-converter)
* [confluentinc/kafka-connect-json-schema-converter:7.1.0](https://www.confluent.io/hub/confluentinc/kafka-connect-json-schema-converter)

## Build

In order to create your own Docker image for Apache Kafka Connect standalone clone the [ueisele/kafka-image](https://github.com/ueisele/kafka-images) Git repository and run the build command:

```bash
git clone https://github.com/ueisele/kafka-images.git
cd kafka-images
connect-standalone/build.sh --build --tag 3.1.0 --openjdk-release 17
```

To create an image with a specific OpenJDK version use the following command:

```bash
connect-standalone/build.sh --build --tag 3.1.0 --openjdk-release 17 --openjdk-version 17.0.2
```

To build the most recent `SNAPSHOT` of Apache Kafka 3.2.0 with Java 17, run:

```bash
connect-standalone/build.sh --build --branch trunk --openjdk-release 17
```

### Build Options

The `connect-standalone/build.sh` script provides the following options:

`Usage: connect-standalone/build.sh [--build] [--push] [--user ueisele] [--github-repo apache/kafka] [ [--commit-sha 37edeed] [--tag 3.1.0] [--branch trunk] [--pull-request 9999] ] [--openjdk-release 17] [--openjdk-version 17.0.2]`

## License 

This Docker image is licensed under the [Apache 2 license](https://github.com/ueisele/kafka-images/blob/main/LICENSE).