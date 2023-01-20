#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})

MODULES=server,connect
VERSIONS=snapshot
MODES=build

DOCKERREGISTRY_USER="ueisele"
KAFKA_GITHUB_REPO="apache/kafka"

function usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--modules server,connect] [--versions release,snapshot] [--modes build,push] [--user ueisele]"
    echo
    return 1
}

function release () {
    local modules=${1:?"Requires modules as first parameter!"}
    local modes=${2:?"Requires modes as second parameter!"}
    doAction "${modules}" "${modes}" "tag" "2.8.0" "11" "2.8.0-grgit.patch"
    doAction "${modules}" "${modes}" "tag" "2.8.1" "11" "2.8.1-grgit.patch"
    doAction "${modules}" "${modes}" "tag" "2.8.2" "11"
    doAction "${modules}" "${modes}" "tag" "3.0.0" "17" "3.0.0-openjdk17.patch"
    doAction "${modules}" "${modes}" "tag" "3.0.1" "17" "3.0.1-openjdk17.patch"
    doAction "${modules}" "${modes}" "tag" "3.0.2" "17" "3.0.2-openjdk17.patch"
    doAction "${modules}" "${modes}" "tag" "3.1.0" "17"
    doAction "${modules}" "${modes}" "tag" "3.1.1" "17"
    doAction "${modules}" "${modes}" "tag" "3.1.2" "17"
    doAction "${modules}" "${modes}" "tag" "3.2.0" "17"
    doAction "${modules}" "${modes}" "tag" "3.2.1" "17"
    doAction "${modules}" "${modes}" "tag" "3.2.2" "17"
    doAction "${modules}" "${modes}" "tag" "3.2.3" "17"
    doAction "${modules}" "${modes}" "tag" "3.3.0" "17"
    doAction "${modules}" "${modes}" "tag" "3.3.1" "17"
    doAction "${modules}" "${modes}" "tag" "3.3.2" "17"
}

function snapshot () {
    local modules=${1:?"Requires modules as first parameter!"}
    local modes=${2:?"Requires modes as second parameter!"}
    doAction "${modules}" "${modes}" "branch" "3.4" "17"
    doAction "${modules}" "${modes}" "branch" "trunk" "17"
}

function doAction () {
    local modules=${1:?"Requires modules as first parameter!"}
    local modes=${2:?"Requires modes as second parameter!"}
    local reftype=${3:?"Requires ref type as third parameter!"}
    local ref=${4:?"Requires ref as forth parameter!"}
    local openjdk=${5:?"Requires openjdk release as fith parameter!"}
    local patch=${6:-}
    ${SCRIPT_DIR}/build.sh --modules "${modules}" --modes "${modes}" \
        --user "${DOCKERREGISTRY_USER}" --github-repo "${KAFKA_GITHUB_REPO}" \
        --${reftype} "${ref}" \
        --openjdk-release "${openjdk}" \
        $([[ -n "${patch}" ]] && echo --patch "${patch}")
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
            --versions)
                shift
                case "$1" in
                    release,snapshot|snapshot,release|release|snapshot)
                        VERSIONS="$1"
                        shift
                        ;;
                    *)
                        usage "Requires release or snapshot as versions"
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

    for version in $(sed "s/,/ /g" <<< ${VERSIONS}); do 
        if [ "${version}" = "release" ]; then
            release "${MODULES}" "${MODES}"
        elif [ "${version}" = "snapshot" ]; then
            snapshot "${MODULES}" "${MODES}"
        fi         
    done
}

main "$@"