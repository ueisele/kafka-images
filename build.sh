#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})

PUSH=false
BUILD=false

DOCKERREGISTRY_USER="ueisele"

KAFKA_GITHUB_REPO="apache/kafka"
KAFKA_BRANCH="2.8.0"

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--build] [--push] [--user ueisele] [--github-repo apache/kafka] --branch 2.8.0"
    echo
    return 1
}

function build_image () {  
    local artifact=${1:?"Missing artifact as first parameter!"}
    docker build \
        -t "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}" \
        --build-arg DOCKERREGISTRY_USER=${DOCKERREGISTRY_USER} \
        --build-arg KAFKA_IMAGE_NAME=${KAFKA_IMAGE_NAME} \
        --build-arg KAFKA_GITREPO=${KAFKA_GITREPO} \
        --build-arg KAFKA_BRANCH=${KAFKA_VERSION} \
        --build-arg KAFKA_VERSION=${KAFKA_VERSION} \
        --build-arg BUILD_TIMESTAMP=$(date +%s) \
        ${SCRIPT_DIR}/${artifact}
    docker tag "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}" "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}-$(resolveBuildTimestamp ${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION})"
    if [ "${KAFKA_VERSION}" != "${KAFKA_ALT_VERSION}" ]; then
        docker tag "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}" "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_ALT_VERSION}-$(resolveBuildTimestamp ${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION})"
        docker tag "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}" "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_ALT_VERSION}"
    fi
    if [ "${RELEASE}" == "true" ]; then
        docker tag "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}" "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:latest"
    fi
}

function build () {
    echo "Building Docker images with Kafka version ${KAFKA_VERSION} (${KAFKA_ALT_VERSION}) using branch ${KAFKA_BRANCH} (release=${RELEASE})"
    #build_image base
    build_image server-minimal
}

function push_image () {
    local artifact=${1:?"Missing artifact as first parameter!"}
    docker push "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}-$(resolveBuildTimestamp ${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION})"
    docker push "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION}"
    if [ "${KAFKA_VERSION}" != "${KAFKA_ALT_VERSION}" ]; then
        docker push "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_ALT_VERSION}-$(resolveBuildTimestamp ${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_VERSION})"
        docker push "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:${KAFKA_ALT_VERSION}"
    fi
    if [ "${RELEASE}" == "true" ]; then
        docker push "${DOCKERREGISTRY_USER}/${KAFKA_IMAGE_NAME}-${artifact}:latest"
    fi
}

function push () {
    echo "Pushing Docker images with Kafka version ${KAFKA_VERSION} to user repository ${DOCKERREGISTRY_USER}"
    push_image base
    push_image server
}

function resolveVersion () {
    local gitrepo=${1:?"Missing git repo as first parameter!"}
    local branch=${2:?"Missing branch as first parameter!"}
    local tmpdir="$(mktemp -d)"
    git clone ${gitrepo} --branch ${branch} "${tmpdir}/kafka" > /dev/null 2>&1
    local version="$(cd "${tmpdir}/kafka" && git describe --tags --abbrev=7)"
    rm -rf ${tmpdir} > /dev/null 2>&1
    echo "$version"
}

function resolveBuildTimestamp () {
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
            --github-repo)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kafka GitHub Repo"
                        return 1
                        ;;
                    *)
                        KAFKA_GITHUB_REPO="$1"
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
    KAFKA_GITREPO="https://github.com/${KAFKA_GITHUB_REPO}.git"
    KAFKA_IMAGE_NAME="${KAFKA_GITHUB_REPO//\//-}"
    KAFKA_VERSION="$(resolveVersion ${KAFKA_GITREPO} ${KAFKA_BRANCH})"
    KAFKA_ALT_VERSION="$(curl -s -L https://raw.githubusercontent.com/${KAFKA_GITHUB_REPO}/${KAFKA_BRANCH}/gradle.properties | sed -n 's/^version=\(.\+\)$/\1/p')"
    if [ "${KAFKA_BRANCH}" == "${KAFKA_VERSION}" ]; then RELEASE="true"; else RELEASE="false"; fi
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