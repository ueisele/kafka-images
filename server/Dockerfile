ARG DOCKERREGISTRY_USER=ueisele
ARG KAFKA_VERSION=2.8.0-rc1

FROM ${DOCKERREGISTRY_USER}/apache-kafka-base:${KAFKA_VERSION}

LABEL maintainer="code@uweeisele.eu"

EXPOSE 9092 9093

COPY --chown=appuser:appuser include/opt/apache/kafka/docker /opt/apache/kafka/docker

CMD ["/opt/apache/kafka/docker/run"]