FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4 as build

LABEL maintainer="code@uweeisele.eu"

# This affects how strings in Java class files are interpreted. 
# We want UTF-8 and this is the only locale in the base image that supports it
ENV LANG="C.UTF-8"

# Zulu openJDK
ENV ZULU_OPENJDK="zulu11-jdk-headless"
ENV JAVA_HOME="/usr/lib/jvm/zulu11"

RUN microdnf install -y dnf \
    && dnf update -y \
    && dnf install -y git openssl wget tar procps krb5-workstation iputils hostname \
    # https://docs.azul.com/zulu/zuludocs/ZuluUserGuide/PrepareZuluPlatform/AttachYumRepositoryRHEL-SLES-OracleLinuxSys.htm
    && rpm --import https://www.azul.com/files/0xB1998361219BD9C9.txt \
    && dnf -y install https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm \
    && dnf -y install ${ZULU_OPENJDK} \
    && dnf clean all \
    && rm -rf /tmp/* \
    && useradd --no-log-init --create-home --shell /bin/bash appuser

USER appuser
WORKDIR /home/appuser

ARG KAFKA_GITREPO=https://github.com/apache/kafka.git
ARG KAFKA_BRANCH=2.8.0
RUN git clone ${KAFKA_GITREPO} --branch ${KAFKA_BRANCH} kafka

RUN cd kafka \
    && ./gradlew jar releaseTarGz

RUN cd kafka/core/build/distributions \
    && dist_file=kafka_*-$(sed -n 's/^version=\(.\+\)$/\1/p' /home/appuser/kafka/gradle.properties).tgz \
    && mkdir -p /home/appuser/distributions/kafka \
    && tar -xzf ${dist_file} --strip-components 1 -C /home/appuser/distributions/kafka \
    && cp /home/appuser/kafka/shell/build/libs/* /home/appuser/distributions/kafka/libs \
    && cp /home/appuser/kafka/shell/build/dependant-libs*/* /home/appuser/distributions/kafka/libs


FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4 as base

LABEL maintainer="code@uweeisele.eu"

# This affects how strings in Java class files are interpreted.  We want UTF-8 and this is the only locale in the
# base image that supports it
ENV LANG="C.UTF-8"

# Zulu openJDK
ENV ZULU_OPENJDK="zulu11-jre-headless"
ENV JAVA_HOME="/usr/lib/jvm/zulu11"

ENV PYTHON_VERSION="38-3.8.6"

RUN microdnf install -y dnf \
    && dnf update -y \
    && dnf install -y git python${PYTHON_VERSION} openssl wget tar procps krb5-workstation iputils hostname \
    # https://docs.azul.com/zulu/zuludocs/ZuluUserGuide/PrepareZuluPlatform/AttachYumRepositoryRHEL-SLES-OracleLinuxSys.htm
    && rpm --import https://www.azul.com/files/0xB1998361219BD9C9.txt \
    && dnf -y install https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm \
    && dnf -y install ${ZULU_OPENJDK} \
    && alternatives --set python /usr/bin/python3 \
    && python3 -m pip install --upgrade pip setuptools \
    && python3 -m pip install --prefer-binary --prefix=/usr/local --upgrade 'git+https://github.com/confluentinc/confluent-docker-utils@v0.0.45' \
    && dnf remove -y git \
    && dnf clean all \
    && rm -rf /tmp/* \
    && useradd --no-log-init --create-home --shell /bin/bash appuser \
    && mkdir -p /opt/apache/kafka /usr/logs \
    && chown appuser:appuser -R /opt/apache/kafka /usr/logs

USER appuser
WORKDIR /home/appuser

COPY --from=build --chown=appuser:appuser /home/appuser/distributions/kafka/bin /opt/apache/kafka/bin
ENV PATH=/opt/apache/kafka/bin:${PATH}

COPY --from=build --chown=appuser:appuser /home/appuser/distributions/kafka/config /opt/apache/kafka/config
COPY --from=build --chown=appuser:appuser /home/appuser/distributions/kafka/libs /opt/apache/kafka/libs

COPY --chown=appuser:appuser include/opt/apache/kafka/docker /opt/apache/kafka/docker

RUN mkdir -p /opt/apache/kafka/data /opt/apache/kafka/secrets
VOLUME ["/opt/apache/kafka/data", "/opt/apache/kafka/secrets"]

ARG KAFKA_GITREPO=https://github.com/apache/kafka.git
ARG KAFKA_BRANCH=2.8.0
LABEL kafka.gitrepo="${KAFKA_GITREPO}"
LABEL kafka.gitref="${KAFKA_BRANCH}"