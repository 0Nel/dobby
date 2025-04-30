#/bin/bash

################################################################### GLOBALS ###
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../config.txt

CHAT_ID=$CHAT_ID
TOKEN=$TOKEN
COOKIE_FILE=/tmp/cookie.txt
HTML_DIR=/tmp
RESULT=""
STRESE_URL="https://termin.bremen.de/termine/location?mdt=800&select_cnc=1&cnc-9234=1"
STRESE_LANDING="https://termin.bremen.de/termine/select2?md=4&lang=de_DE"
MITTE_URL="https://termin.bremen.de/termine/location?mdt=781&select_cnc=1&&cnc-9089=1"
MITTE_LANDING="https://termin.bremen.de/termine/select2?md=5&lang=de_DE"

ACTION="Ummeldung"
MAX_DAYS=30
source "$SCRIPT_DIR/termin_parser.bash"

###################################################################### MAIN ###
COOKIE_URL=$MITTE_LANDING
get_cookie
get_page "BSC-Mitte" $MITTE_URL 
parse_page "BSC-Mitte" $MITTE_LANDING

COOKIE_URL=$STRESE_LANDING
get_cookie
get_page "BSC-Stresemannstrasse" $STRESE_URL
parse_page "BSC-Stresemannstrasse" $STRESE_LANDING
