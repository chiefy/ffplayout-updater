#!/usr/bin/env bash

#
# Usage:
# update.sh [command] [api-token] <jsonrpc-host> <jsonrpc-port> <media-regex>
#
# This script will publish a text message to your ffplayout's stream via a JSONRPC call
# To obtain a token, check the FFPlayout config screen and enable the JSONRPC server
#

set -euo pipefail

if ! which jq &>/dev/null; then
    echo "This script requires jq, install it with your package manager to continue"
    exit 1
fi
if ! which curl &>/dev/null; then
    echo "This script requires curl, install it with your package manager to continue"
    exit 1
fi

CMD=${1:?"no command given"}

FFPLAYOUT_JSONRPC_TOKEN=${2:?"no api token provided"}
FFPLAYOUT_JSONRPC_HOST=${3:-127.0.0.1}
FFPLAYOUT_JSONRPC_PORT=${4:-7070}

MEDIA_PATH_REGEX=${5:-"\/mnt\/Movies\/(.*)\/"}

NEXT_PLAYING_PREFIX="Up next: "
NOW_PLAYING_PREFIX="Now playing: "

TEXT_X=5
TEXT_Y="(h-text_h)"
TEXT_FONT_SIZE=15
TEXT_LINE_HEIGHT=1.4
TEXT_FONT_COLOR="#ffffff@0xcc"
TEXT_ALPHA="0.7"

call_api() {
    local data=${1:?"no rpc command or data provided"}
    curl -Ss \
        -H "Content-Type: application/json" \
        -H "Authorization: ${FFPLAYOUT_JSONRPC_TOKEN}" \
        --data "${data}" \
        http://${FFPLAYOUT_JSONRPC_HOST}:${FFPLAYOUT_JSONRPC_PORT}
}

get_current() {
    local request="{\"media\":\"current\"}"
    call_api ${request}
}

get_next() {
    local request="{\"media\":\"next\"}"
    call_api ${request}
}

fix_media_name() {
    local media=${1:?"no media string provided"}
    local fixed_name="Script Error!"
    if [[ $media =~ $MEDIA_PATH_REGEX ]]; then
        fixed_name=${BASH_REMATCH[1]}
    fi
    printf "%s" "$fixed_name"
}

update_info() {
    local current=$(fix_media_name "$(get_current | jq -r '.media.source')")
    local next=$(fix_media_name "$(get_next | jq -r '.media.source')")

    local data="{\
        \"control\":\"text\",\
        \"id\":1,\
        \"message\":{\
            \"text\":\"${NOW_PLAYING_PREFIX}${current}\n${NEXT_PLAYING_PREFIX}${next}\",\
            \"x\":\"$TEXT_X\",\
            \"y\":\"$TEXT_Y\",\
            \"fontsize\":\"$TEXT_FONT_SIZE\",\
            \"line_spacing\":\"$TEXT_LINE_HEIGHT\",\
            \"fontcolor\":\"$TEXT_FONT_COLOR\",\
            \"alpha\":\"$TEXT_ALPHA\"\
        }}"
    call_api "$(echo "$data" | jq -Mc .)"
}

${CMD}
