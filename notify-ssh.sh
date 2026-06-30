#!/bin/sh -e

MSG="$SSH_ORIGINAL_COMMAND"
notify-send "notify-ssh" "$MSG"

SCRIPT_DIR=$(cd $(dirname $0) ; pwd)
mpv --really-quiet --no-terminal "${SCRIPT_DIR}/message.oga"
