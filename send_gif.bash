#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/config.txt
GIF=https://media.giphy.com/media/GCvktC0KFy9l6/giphy.gif
curl --silent -X POST "https://api.telegram.org/bot$TOKEN/sendVideo" -d "chat_id=$CHAT_ID&video=$GIF" > /dev/null
