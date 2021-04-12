#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR=$(pwd)
popd > /dev/null

PUSH=false
BUILD=false

DOCKERREGISTRY_USER="ueisele"

KAFKA_BRANCH="2.8.0-rc1"

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--build] [--push] [--user <name, e.g. ueisele>] --branch <kafka-branch, e.g. 2.8.0-rc1>"
    echo
    return 1
}

function build_image () {  
    local artifact=${1:?"Missing artifact as first parameter!"}
    docker build \
        -t "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION}" \
        --build-arg DOCKERREGISTRY_USER=${DOCKERREGISTRY_USER} \
        --build-arg KAFKA_BRANCH=${KAFKA_BRANCH} \
        --build-arg KAFKA_VERSION=${KAFKA_VERSION} \
        ${SCRIPT_DIR}/${artifact}
    docker tag "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION}" "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION}-$(resolveBuildTimestamp ${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION})"
    docker tag "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION}" "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:latest"
}

function build () {
    echo "Building Docker images with Kafka version ${KAFKA_VERSION} using branch ${KAFKA_BRANCH}"
    build_image base
    build_image server
}

function push_image () {
    local artifact=${1:?"Missing artifact as first parameter!"}
    docker push "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION}-$(resolveBuildTimestamp ${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION})"
    docker push "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:${KAFKA_VERSION}"
    docker push "${DOCKERREGISTRY_USER}/apache-kafka-${artifact}:latest"
}

function push () {
    echo "Pushing Docker images with Kafka version ${KAFKA_VERSION} to user repository ${DOCKERREGISTRY_USER}"
    push_image base
    push_image server
}

function resolveBuildTimestamp() {
    local imageName=${1:?"Missing image name as first parameter!"}
    local created=$(docker inspect --format "{{ index .Created }}" "${imageName}")
    date --utc -d "${created}" +'%Y%m%dT%H%M%Z'
}

function parseCmd () {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --build)
                BUILD=true
                shift
                ;;
            --push)
                PUSH=true
                shift
                ;;
            --user)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Docker registry user name"
                        return 1
                        ;;
                    *)
                        DOCKERREGISTRY_USER="$1"
                        shift
                        ;;
                esac
                ;;
            --branch)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kafka branch"
                        return 1
                        ;;
                    *)
                        KAFKA_BRANCH="$1"
                        shift
                        ;;
                esac
                ;;
            *)
                usage "Unknown option: $1"
                return $?
                ;;
        esac
    done
    if [[ "${KAFKA_BRANCH}" == *"-rc"* ]]; then
        KAFKA_VERSION="${KAFKA_BRANCH}"
    else
        KAFKA_VERSION="$(curl -s -L https://raw.githubusercontent.com/apache/kafka/${KAFKA_BRANCH}/gradle.properties | sed -n 's/^version=\(.\+\)$/\1/p')"
    fi
    return 0
}

function main () {
    parseCmd "$@"
    local retval=$?
    if [ $retval != 0 ]; then
        exit $retval
    fi

    if [ "$BUILD" = true ]; then
        build
    fi
    if [ "$PUSH" = true ]; then
        push
    fi
}

main "$@"