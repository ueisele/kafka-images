# Docker Image for Kcat

Check out [edenhill/kcat](https://github.com/edenhill/kcat) for more information.

The Docker images are available in the following repositories on DockerHub:

* [ueisele/kcat](https://hub.docker.com/repository/docker/ueisele/kcat)

## Most Recent Tags

* `1.7.1`, `1.7.1-librdkafka2.0.2`, `1.7.1-librdkafka2.0.2-ubi8.7`, `1.7.1-librdkafka2.0.2-ubi8.7-1049`

## Image

The Docker image is based on [RedHat's Universal Base Image 8](https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/5c359a62bed8bd75a2c3fba8). If a new version of the base image is released, typically also a new version of this Docker image is created and published.

## Usage

To run a container of your choice, use commands below as an example.

```bash
docker run --rm ueisele/kcat:1.7.1
```

## Build

In order to create your own Kcat Docker image clone the [ueisele/kafka-image](https://github.com/ueisele/kafka-images) Git repository and run the build command for the Kcat image:

```bash
git clone https://github.com/ueisele/kafka-images.git
cd kafka-images
kcat/build.sh --build --user ueisele --tag 1.7.1
```
## License 

This Docker image is licensed under the [Apache 2 license](https://github.com/ueisele/kafka-images/blob/main/LICENSE).