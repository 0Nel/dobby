#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/config.txt
MSG="Hello World."
curl --silent -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "parse_mode=HTML&chat_id=$CHAT_ID&text=$MSG" > /dev/null
