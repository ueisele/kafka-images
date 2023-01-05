# Docker Image for Azul Zulu OpenJDK 

Azul Zulu builds of OpenJDK are fully tested and TCK compliant builds of OpenJDK.

Check out [Azul Zulu Overview](https://www.azul.com/downloads/?package=jdk) for more information.

The Docker images are available in the following repositories on DockerHub:

* [ueisele/openjdk-jdk](https://hub.docker.com/repository/docker/ueisele/openjdk-jdk)
* [ueisele/openjdk-jre](https://hub.docker.com/repository/docker/ueisele/openjdk-jre)

## Most Recent Tags

* `zulu17`, `zulu17.0.5`, `zulu17-ubi8.6`, `zulu17.0.5-ubi8.7-1031`
* `zulu11`, `zulu11.0.17`, `zulu11-ubi8.6`, `zulu11.0.17-ubi8.7-1031`
* `zulu8`, `zulu8.0.352`, `zulu8-ubi8.6`, `zulu8.0.352-ubi8.7-1031` 

## Image

The source files for the images are available on [GitHub](https://github.com/ueisele/kafka-images/tree/main/openjdk).

The Docker image is based on [RedHat's Universal Base Image 8](https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/5c359a62bed8bd75a2c3fba8). If a new version of the base image is released, typically also a new version of this Docker image is created and published.

Azul already provides Docker images with Azul Zulu OpenJDK at their [DockerHub repository](https://hub.docker.com/r/azul/zulu-openjdk-centos).
We decided to create our own image, because we wanted to use [RedHat's Universal Base Image 8](https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/5c359a62bed8bd75a2c3fba8).
In addition our image is much smaller, than the original [Azul Zulu OpenJDK Docker image](https://hub.docker.com/r/azul/zulu-openjdk-centos).

## Usage

To run a container of your choice, use commands below as an example.

For Azul Zulu OpenJDK 17, run:

```bash
docker run --rm ueisele/openjdk-jre:zulu17 java -version
```

## Build

In order to create your own Azul Zulu OpenJDK Docker image clone the [ueisele/kafka-image](https://github.com/ueisele/kafka-images) Git repository and run the build command for the OpenJDK image:

```bash
git clone https://github.com/ueisele/kafka-images.git
cd kafka-images
openjdk/build.sh --build --user ueisele --openjdk-release 17
```

To create an image with a specific OpenJDK version use the following command:

```bash
openjdk/build.sh --build --user ueisele --openjdk-release 11 --openjdk-version 11.0.16
```

## License 

This Docker image is licensed under the [Apache 2 license](https://github.com/ueisele/kafka-images/blob/main/LICENSE).