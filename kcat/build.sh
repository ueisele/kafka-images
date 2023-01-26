#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source ${SCRIPT_DIR}/env

PUSH=false
BUILD=false

CONTAINERFILE=Containerfile.ubi8

DOCKERREGISTRY_USER="ueisele"
KCAT_GITHUB_REPO="edenhill/kcat"
KAFKA_GIT_BRANCH="master"
LIBRDKAFKA_VERSION="2.0.2"

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--build] [--push] [--user ueisele] [--github-repo edenhill/kcat] [ [--commit-sha 9ca33cd] [--tag 1.7.1] [--branch master] [--pull-request 9999] ] [--librdkafka-version 2.0.2]"
    echo
    return 1
}

function image_name () {
    local git_repo="${1:?"Missing Git repo as first parameter!"}"
    local name="${KCAT_GITHUB_REPO//\//-}"
    echo ${name/edenhill-/}
}

function build_image () {  
    local tags=($(kcat_image_tags "${KCAT_VERSION}" "${LIBRDKAFKA_VERSION}"))
    docker build \
        $(for tag in "${tags[@]}"; do
        echo -t "$(kcat_image_name ${DOCKERREGISTRY_USER} ${KCAT_GIT_REPO}):${tag}"
        done) \
        --build-arg UBI8_VERSION=${UBI8_VERSION} \
        --build-arg KCAT_GIT_REPO=${KCAT_GIT_REPO} \
        --build-arg KCAT_GIT_REFSPEC=${KCAT_GIT_COMMIT_SHA} \
        --build-arg KCAT_BUILD_GIT_REFSPEC=${KCAT_BUILD_GIT_REFSPEC} \
        --build-arg KCAT_VERSION=${KCAT_VERSION} \
        --build-arg LIBRDKAFKA_VERSION="${LIBRDKAFKA_VERSION}" \
        -f ${SCRIPT_DIR}/${CONTAINERFILE} ${SCRIPT_DIR}
}

function build () {
    echo "Building Docker images with Kcat version ${KCAT_VERSION} (${KCAT_GIT_COMMIT_SHA}) from ${KCAT_BUILD_GIT_REFSPEC} and librdkafka version ${LIBRDKAFKA_VERSION}."
    build_image
}

function push_image () {
    local tags=($(kcat_image_tags "${KCAT_VERSION}" "${LIBRDKAFKA_VERSION}"))
    for tag in "${tags[@]}"; do
        docker push "$(kcat_image_name ${DOCKERREGISTRY_USER} ${KCAT_GIT_REPO}):${tag}"
    done
}

function push () {
    echo "Pushing Docker images with Kcat version ${KCAT_VERSION} (${KCAT_GIT_COMMIT_SHA}) from ${KCAT_BUILD_GIT_REFSPEC} and librdkafka version ${LIBRDKAFKA_VERSION}."
    push_image
}

function resolveKcatVersion () {
    local git_repo="${1:?"Missing Kcat Git repo as first parameter!"}"
    local git_refspec="${2:-""}"
    local tmpdir="$(mktemp -d --suffix=kcat)"
    (git clone ${git_repo} "${tmpdir}" > /dev/null)
    (cd ${tmpdir} && git checkout ${git_refspec} > /dev/null)
    (cd ${tmpdir} && git describe --tags --abbrev=7)
    rm -rf "${tmpdir}"
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
                        usage "Requires Kcat GitHub Repo"
                        return 1
                        ;;
                    *)
                        KCAT_GITHUB_REPO="$1"
                        shift
                        ;;
                esac
                ;;
            --commit-sha)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kcat Git Commit-Sha"
                        return 1
                        ;;
                    *)
                        KCAT_GIT_COMMIT_SHA="$1"
                        shift
                        ;;
                esac
                ;;
            --tag)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kcat Git Tag"
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
                        usage "Requires Kcat Git Branch"
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
                        usage "Requires Kcat Git pull request number"
                        return 1
                        ;;
                    *)
                        KAFKA_GIT_PULL_REQUEST="$1"
                        shift
                        ;;
                esac
                ;;
            --librdkafka-version)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires librdkafka version"
                        return 1
                        ;;
                    *)
                        LIBRDKAFKA_VERSION="$1"
                        shift
                        ;;
                esac
                ;;                                    
            *)
                local param="$1"
                shift
                case "$1" in
                    ""|--*)
                        echo "WARN: Unknown option: ${param}"
                        ;;
                    *)
                        echo "WARN: Unknown option: ${param} $1"
                        shift
                        ;;
                esac
                ;;
        esac
    done
    
    KCAT_GIT_REPO="https://github.com/${KCAT_GITHUB_REPO}.git"

    if [ -n "${KCAT_GIT_COMMIT_SHA}" ]; then
        KCAT_BUILD_GIT_REFSPEC="commit/${KCAT_GIT_COMMIT_SHA}"
        KCAT_VERSION="$(resolveKcatVersion ${KCAT_GIT_REPO} ${KCAT_GIT_COMMIT_SHA})"
    elif [ -n "${KAFKA_GIT_TAG}" ]; then
        KCAT_GIT_COMMIT_SHA=$(git ls-remote --tags ${KCAT_GIT_REPO} "refs/tags/${KAFKA_GIT_TAG}" | awk '{ print $1}')
        KCAT_BUILD_GIT_REFSPEC="tags/${KAFKA_GIT_TAG}"
        KCAT_VERSION=${KAFKA_GIT_TAG}
    elif [ -n "${KAFKA_GIT_PULL_REQUEST}" ]; then
        KCAT_GIT_COMMIT_SHA=$(git ls-remote --refs ${KCAT_GIT_REPO} refs/pull/${KAFKA_GIT_PULL_REQUEST}/head | awk '{ print $1}')
        KCAT_BUILD_GIT_REFSPEC="pull/${KAFKA_GIT_PULL_REQUEST}"
        KCAT_VERSION="${KCAT_BUILD_GIT_REFSPEC//\//}-$(resolveKcatVersion ${KCAT_GIT_REPO} ${KCAT_GIT_COMMIT_SHA})"
    elif [ -n "${KAFKA_GIT_BRANCH}" ]; then
        KCAT_GIT_COMMIT_SHA=$(git ls-remote --heads ${KCAT_GIT_REPO} refs/heads/${KAFKA_GIT_BRANCH} | awk '{ print $1}')
        KCAT_BUILD_GIT_REFSPEC="heads/${KAFKA_GIT_BRANCH}"
        KCAT_VERSION="$(resolveKcatVersion ${KCAT_GIT_REPO} ${KCAT_GIT_COMMIT_SHA})"
        if ! [ "${KAFKA_GIT_BRANCH}" == "master" ] && ! [[ "${KCAT_VERSION}" =~ ^${KAFKA_GIT_BRANCH} ]]; then
            KCAT_VERSION="${KAFKA_GIT_BRANCH}-${KCAT_VERSION}"
        fi
    fi

    if [ -z "${KCAT_VERSION}" ] || [ -z "${KCAT_GIT_COMMIT_SHA}" ]; then
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