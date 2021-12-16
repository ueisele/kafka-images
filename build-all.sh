#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})

PUSH=false
BUILD=false

RELEASE=false
SNAPSHOT=false

DOCKERREGISTRY_USER="ueisele"
KAFKA_GITHUB_REPO="apache/kafka"

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--build] [--push] [--release] [--snapshot] [--user ueisele]"
    echo
    return 1
}

function release () {
    local mode=${1:?"Requires mode as first parameter!"}
    doAction "${mode}" "tag" "2.8.0" "11" "2.8.0-grgit.patch"
    doAction "${mode}" "tag" "2.8.1" "11" "2.8.1-grgit.patch"
    doAction "${mode}" "tag" "3.0.0" "17" "3.0.0-openjdk17.patch"
}

function snapshot () {
    local mode=${1:?"Requires mode as first parameter!"}
    doAction "${mode}" "branch" "3.1" "17" "3.1.0-openjdk17.patch"
    doAction "${mode}" "branch" "trunk" "17" "3.2.0-openjdk17.patch"
}

function doAction () {
    local mode=${1:?"Requires build or push as first parameter!"}
    local reftype=${2:?"Requires ref type as second parameter!"}
    local ref=${3:?"Requires ref as third parameter!"}
    local openjdk=${4:?"Requires openjdk release as forth parameter!"}
    local patch=${5:-}
    ${SCRIPT_DIR}/build.sh --${mode} \
        --user "${DOCKERREGISTRY_USER}" --github-repo "${KAFKA_GITHUB_REPO}" \
        --${reftype} "${ref}" \
        --openjdk-release "${openjdk}" \
        $([[ -n "${patch}" ]] && echo --patch "${patch}")
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
            --release)
                RELEASE=true
                shift
                ;;
            --snapshot)
                SNAPSHOT=true
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

    if [ "$BUILD" = false ] && [ "$PUSH" = false ]; then
        usage "--build or --push required"
        return $? 
    fi

        if [ "$RELEASE" = false ] && [ "$SNAPSHOT" = false ]; then
        usage "--release or --snapshot required"
        return $? 
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
        [[ "${RELEASE}" = true ]] && release "build"
        [[ "${SNAPSHOT}" = true ]] && snapshot "build"
    fi
    if [ "$PUSH" = true ]; then
        [[ "${RELEASE}" = true ]] && release "push"
        [[ "${SNAPSHOT}" = true ]] && snapshot "push"
    fi
}

main "$@"