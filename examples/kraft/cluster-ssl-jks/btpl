#!/usr/bin/env bash
set -e

function btpl () {
    local tplfile="${1:?Missing template file as first parameter!}"
    local targetfile="${2:?Missing target file as first parameter!}"
    cd "$(dirname "${tplfile}")" && eval "cat <<EOF
$(<${tplfile})
EOF
" 2> /dev/null > "${targetfile}"
    ls -alh "${targetfile}"
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
  btpl "$@"
fi