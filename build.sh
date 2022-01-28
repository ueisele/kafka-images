#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})

MODULES=server,connect
MODES=build

DOCKERREGISTRY_USER="ueisele"
KAFKA_GITHUB_REPO="apache/kafka"
ZULU_OPENJDK_RELEASE=11

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--modules server,connect] [--modes build,push] [--user ueisele] [--github-repo apache/kafka] [ [--commit-sha 37edeed] [--tag 3.1.0] [--branch trunk] [--pull-request 9999] ] [--openjdk-release 17] [--openjdk-version 17.0.2] [--patch 3.0.0-openjdk17.patch]"
    echo
    return 1
}

function doServer () {
    local modes=${1:?"Requires 'build' or 'push' or 'build,push' as first parameter!"}
    doAction "${modes}" "server"
    doAction "${modes}" "server-standalone"
}

function doConnect () {
    local modes=${1:?"Requires 'build' or 'push' or 'build,push' as first parameter!"}
    doAction "${modes}" "connect-base"
    doAction "${modes}" "connect"
    doAction "${modes}" "connect-standalone"
}

function doAction () {
    local modes=${1:?"Requires 'build' or 'push' or 'build,push' as first parameter!"}
    local artifact=${2:?"Requires artifact as second parameter!"}
    ${SCRIPT_DIR}/${artifact}/build.sh \
        $(for mode in $(sed "s/,/ /g" <<< ${modes}); do echo --${mode} ; done) \
        --user "${DOCKERREGISTRY_USER}" --github-repo "${KAFKA_GITHUB_REPO}" \
        $([[ -n "${KAFKA_GIT_COMMIT_SHA}" ]] && echo --commit-sha "${KAFKA_GIT_COMMIT_SHA}") \
        $([[ -n "${KAFKA_GIT_TAG}" ]] && echo --tag "${KAFKA_GIT_TAG}") \
        $([[ -n "${KAFKA_GIT_BRANCH}" ]] && echo --branch "${KAFKA_GIT_BRANCH}") \
        $([[ -n "${KAFKA_GIT_PULL_REQUEST}" ]] && echo --pull-request "${KAFKA_GIT_PULL_REQUEST}") \
        --openjdk-release "${ZULU_OPENJDK_RELEASE}" \
        $([[ -n "${ZULU_OPENJDK_VERSION}" ]] && echo --openjdk-version "${ZULU_OPENJDK_VERSION}") \
        $([[ -n "${KAFKA_PATCH}" ]] && echo --patch "${KAFKA_PATCH}")
}

function parseCmd () {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --modules)
                shift
                case "$1" in
                    server,connect|connect,server|server|connect)
                        MODULES="$1"
                        shift
                        ;;
                    *)
                        usage "Requires server or connect as modules"
                        return 1
                        ;;
                esac
                ;;
            --modes)
                shift
                case "$1" in
                    build,push|push,build|build|push)
                        MODES="$1"
                        shift
                        ;;
                    *)
                        usage "Requires build or push as modes"
                        return 1
                        ;;
                esac
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
            --openjdk-release)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires OpenJDK release"
                        return 1
                        ;;
                    *)
                        ZULU_OPENJDK_RELEASE="$1"
                        shift
                        ;;
                esac
                ;;   
            --openjdk-version)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires OpenJDK version"
                        return 1
                        ;;
                    *)
                        ZULU_OPENJDK_VERSION="$1"
                        shift
                        ;;
                esac
                ;;   
            --patch)
                shift
                case "$1" in
                    ""|--*)
                        usage "Requires Kafka patch name"
                        return 1
                        ;;
                    *)
                        KAFKA_PATCH="$1"
                        shift
                        ;;
                esac
                ;;                                    
            --help)
                usage
                return 0
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

    for module in $(sed "s/,/ /g" <<< ${MODULES}); do 
        if [ "${module}" = "server" ]; then
            doServer "${MODES}"
        elif [ "${module}" = "connect" ]; then
            doConnect "${MODES}"
        fi         
    done
}

main "$@"