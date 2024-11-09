#/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

week=$(date +%U)
if [ $( echo "$week % 2" | bc ) == 0 ]; then 
    ARG="Bio"
else 
    ARG="Papier"
fi

python3 $SCRIPT_DIR/modules/garbage_poll.py $ARG
