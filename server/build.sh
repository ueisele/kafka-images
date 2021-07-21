#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source ${SCRIPT_DIR}/env
source ${SCRIPT_DIR}/../openjdk/env

PUSH=false
BUILD=false

DOCKERFILE=Dockerfile.ubi8

DOCKERREGISTRY_USER="ueisele"
KAFKA_GITHUB_REPO="apache/kafka"

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--build] [--push] [--user ueisele] [--github-repo apache/kafka] [[--commit-sha 7f7dc35] [--tag 2.8.0] [--branch trunk] [--pull-request 9999]}"
    echo
    return 1
}

function build_image () {  
    docker build \
        $(for tag in $(kafka_server_image_tags ${KAFKA_TAG_VERSION} $(echo ${KAFKA_GIT_COMMIT_SHA} | cut -c 1-7) ${OPENJDK_IMAGE_TAGS[@]}); do
        echo -t "$(kafka_server_image_name ${DOCKERREGISTRY_USER} ${KAFKA_GITHUB_REPO}):${tag}"
        done) \
        --build-arg OPENJDK_JDK_IMAGE=$(openjdk_image_name_and_tag ${DOCKERREGISTRY_USER} jdk) \
        --build-arg OPENJDK_JRE_IMAGE=$(openjdk_image_name_and_tag ${DOCKERREGISTRY_USER} jre) \
        --build-arg KAFKA_GIT_REPO=${KAFKA_GIT_REPO} \
        --build-arg KAFKA_GIT_REFSPEC=${KAFKA_GIT_COMMIT_SHA} \
        --build-arg KAFKA_BUILD_GIT_REFSPEC=${KAFKA_BUILD_GIT_REFSPEC} \
        --build-arg KAFKA_VERSION=${KAFKA_VERSION} \
        -f ${SCRIPT_DIR}/${DOCKERFILE} ${SCRIPT_DIR}
}

function build () {
    echo "Building Docker images with Kafka version ${KAFKA_VERSION} (${KAFKA_GIT_COMMIT_SHA}) from ${KAFKA_BUILD_GIT_REFSPEC}."
    build_image
}

function push_image () {
    for tag in $(kafka_server_image_tags ${KAFKA_TAG_VERSION} $(echo ${KAFKA_GIT_COMMIT_SHA} | cut -c 1-7) ${OPENJDK_IMAGE_TAGS[@]}); do
        docker push "$(kafka_server_image_name ${DOCKERREGISTRY_USER} ${KAFKA_GITHUB_REPO}):${tag}"
    done
}

function push () {
    echo "Pushing Docker images with Kafka version ${KAFKA_VERSION} (${KAFKA_GIT_COMMIT_SHA}) from ${KAFKA_BUILD_GIT_REFSPEC}."
    push_image
}

function resolveKafkaVersion () {
    local git_repo=${1:?"Missing Kafka Git repo as first parameter!"}
    local kafka_git_commit_sha=${2:-""}
    curl -s -L https://raw.githubusercontent.com/${git_repo}/${kafka_git_commit_sha}/gradle.properties | sed -n 's/^version=\(.\+\)$/\1/p'
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
            --commit-sha)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kafka Git Commit-Sha"
                        return 1
                        ;;
                    *)
                        KAFKA_GIT_COMMIT_SHA="$1"
                        shift
                        ;;
                esac
                ;;
            --tag)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kafka Git Tag"
                        return 1
                        ;;
                    *)
                        KAFKA_GIT_TAG="$1"
                        shift
                        ;;
                esac
                ;;
            --branch)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kafka Git Branch"
                        return 1
                        ;;
                    *)
                        KAFKA_GIT_BRANCH="$1"
                        shift
                        ;;
                esac
                ;;
            --pull-request)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kafka Git pull request number"
                        return 1
                        ;;
                    *)
                        KAFKA_GIT_PULL_REQUEST="$1"
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
    
    KAFKA_GIT_REPO="https://github.com/${KAFKA_GITHUB_REPO}.git"

    if [ -n "${KAFKA_GIT_COMMIT_SHA}" ]; then
        KAFKA_BUILD_GIT_REFSPEC="commit/${KAFKA_GIT_COMMIT_SHA}"
        KAFKA_VERSION="$(resolveKafkaVersion ${KAFKA_GITHUB_REPO} ${KAFKA_GIT_COMMIT_SHA})"
        KAFKA_TAG_VERSION="${KAFKA_VERSION}-g$(echo ${KAFKA_GIT_COMMIT_SHA} | cut -c 1-7)"
    elif [ -n "${KAFKA_GIT_TAG}" ]; then
        KAFKA_GIT_COMMIT_SHA=$(git ls-remote --tags ${KAFKA_GIT_REPO} "refs/tags/${KAFKA_GIT_TAG}^{}" | awk '{ print $1}')
        KAFKA_BUILD_GIT_REFSPEC="tags/${KAFKA_GIT_TAG}"
        KAFKA_VERSION=${KAFKA_GIT_TAG}
        KAFKA_TAG_VERSION=${KAFKA_GIT_TAG}
    elif [ -n "${KAFKA_GIT_BRANCH}" ]; then
        KAFKA_GIT_COMMIT_SHA=$(git ls-remote --heads ${KAFKA_GIT_REPO} refs/heads/${KAFKA_GIT_BRANCH} | awk '{ print $1}')
        KAFKA_BUILD_GIT_REFSPEC="heads/${KAFKA_GIT_BRANCH}"
        KAFKA_VERSION="$(resolveKafkaVersion ${KAFKA_GITHUB_REPO} ${KAFKA_GIT_COMMIT_SHA})"
        if [ "${KAFKA_GIT_BRANCH}" == "trunk" ] || [[ "${KAFKA_VERSION}" =~ ^${KAFKA_GIT_BRANCH} ]]; then
            KAFKA_TAG_VERSION="${KAFKA_VERSION}"
        else 
            KAFKA_TAG_VERSION="${KAFKA_GIT_BRANCH}"
        fi
    elif [ -n "${KAFKA_GIT_PULL_REQUEST}" ]; then
        KAFKA_GIT_COMMIT_SHA=$(git ls-remote --refs ${KAFKA_GIT_REPO} refs/pull/${KAFKA_GIT_PULL_REQUEST}/head | awk '{ print $1}')
        KAFKA_BUILD_GIT_REFSPEC="pull/${KAFKA_GIT_PULL_REQUEST}"
        KAFKA_VERSION="$(resolveKafkaVersion ${KAFKA_GITHUB_REPO} ${KAFKA_GIT_COMMIT_SHA})"
        KAFKA_TAG_VERSION="${KAFKA_BUILD_GIT_REFSPEC//\//}"
    fi

    if [ -z "${KAFKA_VERSION}" ] || [ -z "${KAFKA_GIT_COMMIT_SHA}" ]; then
        usage "commit-sha, tag, branch or pull-request is invalid"
        return 1
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