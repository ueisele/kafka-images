#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source ${SCRIPT_DIR}/env

PUSH=false
BUILD=false

DOCKERFILE=Dockerfile.ubi8-zulu

DOCKERREGISTRY_USER="ueisele"
IMAGE_NAME="openjdk${ZULU_OPENJDK_RELEASE}-${ZULU_OPENJDK_PACKAGE}"
IMAGE_TAG="${ZULU_OPENJDK_VERSION}-zulu-ubi${UBI8_VERSION}"
IMAGE_TAGS=("${ZULU_OPENJDK_VERSION}-zulu-ubi${UBI8_VERSION}" "${ZULU_OPENJDK_VERSION}-zulu" "${ZULU_OPENJDK_VERSION}" "${ZULU_OPENJDK_RELEASE}")

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--build] [--push] [--user ueisele]"
    echo
    return 1
}

function build_image () {  
    local package=${1:?"Missing package as first parameter!"}
    docker build \
        $(for tag in "${OPENJDK_IMAGE_TAGS[@]}"; do
        echo -t "$(openjdk_image_name ${DOCKERREGISTRY_USER} ${package}):${tag}"
        done) \
        --build-arg UBI8_VERSION=${UBI8_VERSION} \
        --build-arg ZULU_OPENJDK_RELEASE=${ZULU_OPENJDK_RELEASE} \
        --build-arg ZULU_OPENJDK_VERSION=${ZULU_OPENJDK_VERSION} \
        --build-arg ZULU_OPENJDK_PACKAGE=${package} \
        -f ${SCRIPT_DIR}/${DOCKERFILE} ${SCRIPT_DIR}
}

function build () {
    echo "Building Docker images for Zulu OpenJDK ${ZULU_OPENJDK_VERSION} with Ubi ${UBI8_VERSION}."
    for package in "${ZULU_OPENJDK_PACKAGES[@]}"; do
        build_image ${package}
    done
}

function push_image () {
    local package=${1:?"Missing package as first parameter!"}
    for tag in "${OPENJDK_IMAGE_TAGS[@]}"; do
        docker push "$(openjdk_image_name ${DOCKERREGISTRY_USER} ${package}):${tag}"
    done
}

function push () {
    echo "Pushing Docker images for Zulu OpenJDK ${ZULU_OPENJDK_VERSION} with Ubi ${UBI8_VERSION}."
    for package in "${ZULU_OPENJDK_PACKAGES[@]}"; do
        push_image ${package}
    done
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
            *)
                usage "Unknown option: $1"
                return $?
                ;;
        esac
    done
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