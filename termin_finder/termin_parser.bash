#/bin/bash
#set -e

if [ -z $MAX_DAYS ]; then
    echo $(date): "MAX_DAYS is unset!"
    exit 1
fi

################################################################# FUNCTIONS ###
function get_cookie()
{
    curl --silent -o /dev/null --cookie-jar $COOKIE_FILE -X GET $COOKIE_URL 
    COOKIE_NAME=$(tail -1 $COOKIE_FILE | awk '{print $6}')
    COOKIE_VALUE=$(tail -1 $COOKIE_FILE | awk '{print $7}')
    if [ -z $COOKIE_NAME ]; then 
        RESULT="Could not aquire a cookie from $COOKIE_FILE"
        echo $(date): $RESULT
        curl --silent -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "parse_mode=HTML&chat_id=$DEBUG_CHAT_ID&text=$RESULT" > /dev/null
        exit 13
    fi
    echo $(date): "Got Cookie: $COOKIE_NAME=$COOKIE_VALUE"
}

function get_page()
{
    HTML=${HTML_DIR}/$(date "+%Y-%m-%d-%H_%M")_$1_$ACTION.html
    echo $(date): "Fetching page: $2"
    echo $(date): "Storing page to $HTML"
    curl --silent -c $COOKIE_FILE -o $HTML --request GET $2 --header "Cookie: $COOKIE_NAME=$COOKIE_VALUE"
}

function parse_page()
{
    echo $(date): "Parsing page $HTML"
    if ! [ -f "$HTML" ]; then
        RESULT="Could not locate html file: $HTML"
        echo $(date): $RESULT
        curl --silent -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "parse_mode=HTML&chat_id=$DEBUG_CHAT_ID&text=$RESULT" > /dev/null
        exit 13
    fi
    grep -q "Aktuell sind leider keine Termine frei" $HTML
    TERMIN=$?
    grep -q "Es ist ein Fehler aufgetreten" $HTML
    ERROR=$?
    if [ "$TERMIN" -eq "0" ]; then
        RESULT="Es ist leider kein Termin zur $ACTION im $1 frei! %F0%9F%98%A5%0A"
        ID=$DEBUG_CHAT_ID
        echo $(date): "$RESULT"
        echo $(date): "Removing $HTML"
        rm $HTML
    elif [ "$ERROR" -eq "0" ]; then
        RESULT="Bei der Suche nach $ACTION im $1 ist leider ein Fehler aufgetreten! %F0%9F%98%A5%0A"
        ID=$DEBUG_CHAT_ID
        echo $(date): "$RESULT"
    else
        NEXT_DATE_RAW=$(grep -oP '(?<=<dd>)ab \d{2}\.\d{2}\.\d{4}(?=,)' $HTML)
        if [ "$?" -eq "0" ]; then
            NEXT_DATE=$(echo $NEXT_DATE_RAW | sed 's/ab //')
            echo $(date): "Nächster freier Termin am: $NEXT_DATE"
            is_next_date_relevant $NEXT_DATE
            if [ "$?" -eq "0" ]; then
                RESULT="Es sind gerade Termine zur $ACTION im $1 ab $NEXT_DATE frei! %F0%9F%99%8C%0A%0D%0A$2"
                ID=$CHAT_ID
                echo $(date): "$RESULT"
            fi
        else
            echo $(date): "Es konnte kein freier Termin gefunden werden"
        fi
    fi

    curl --silent -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "parse_mode=HTML&chat_id=$ID&text=$RESULT" > /dev/null
}

function is_next_date_relevant()
{
    get_time_diff $1
    DAYS_DIFF=$?
    if [ $DAYS_DIFF -gt $MAX_DAYS ]; then
        echo $(date): "Der nächste Termin ist nicht im angegeben Zeitraum"
        return 1
    else
        return 0
    fi
}

function get_time_diff()
{
    next_date=$1
    current_date=$(date +%d.%m.%Y)
    
    # Convert both dates to a format suitable for calculation: yyyy-mm
    date_next=$(echo "$next_date" | awk -F. '{ print $3 "-" $2 "-" $1 }')
    date_now=$(date +%Y-%m-%d)
    epoch_next=$(date -d "$date_next" +%s)
    epoch_now=$(date -d "$date_now" +%s)
    seconds_diff=$((epoch_next - epoch_now))
    days_diff=$((seconds_diff / 86400))
    echo $(date): "Zwischen $next_date und $current_date liegen $days_diff Tage"
    return $days_diff
}
