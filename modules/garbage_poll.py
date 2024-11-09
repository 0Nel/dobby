#!/bin/python

####################################################################################### IMPORTS ###
from datetime import datetime
from numpy import loadtxt
from ThreadSaveTimer import ThreadSaveTimer
from utils import load_variables_from_file
import os
import random
import requests
import time
import sys

from telegram import (
    Bot,
    Poll,
    ParseMode,
    Update,
)
from telegram.ext import (
    Updater,
    PollAnswerHandler,
    CallbackContext,
)

####################################################################################### GLOBALS ###
CONFIG = load_variables_from_file(os.path.dirname(os.path.abspath(__file__))+"/../config.txt")
API_ENDPOINT="https://api.telegram.org/bot"+CONFIG["TOKEN"]+"/sendPoll"
OPTIONS = ["Erledigt!", "Ich würd ja, aber ich kann nicht.", "Ich fühls heut nicht."]
FinalReminderTimer = ThreadSaveTimer(5*60*60) # in seconds
FOUND_SOMEONE = False
THANKS_FILE=os.path.dirname(os.path.abspath(__file__))+"/../data/chatgpt_dankt.txt"
LINES = loadtxt(THANKS_FILE, dtype = str, comments="#", delimiter="\n", unpack=False)

####################################################################################### METHODS ###
def timestring():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def log(msg):
    print(timestring(), msg)

def send_poll(specifier_string):
    try:
        response = requests.post(
            f'{API_ENDPOINT}',
            json={
                'chat_id': CONFIG["CHAT_ID"],
                'question': "Wer kann heute bitte " + specifier_string +  " rausstellen? \U0001f64f",
                'options': OPTIONS,
                'is_anonymous': False,
                'allows_multiple_answers': False
            }
        )
    
        if response.status_code == 200:
            poll_id = response.json()['result']['poll']['id']
            log(f'Successfully sent poll with ID: {poll_id}')
            return poll_id
        else:
            log(f'Failed to send poll. Response: {response.text}')
            return -1
    except requests.exceptions.NewConnectionError as e:
        log(f"Caught a NewConnectionError: {e}")
    except Exception as e:
        log(f"Caught a generic exception: {e}")
        
def receive_poll_answer(update: Update, context: CallbackContext, poll_id) -> None:
    global FOUND_SOMEONE
    answer = update.poll_answer
    if poll_id != answer.poll_id:
        log("Got a missmatch in poll_id. Discarding received answer")
        return 

    selected_options = answer.option_ids
    try:
        choice_index = selected_options[0]
    except IndexError as e:
        log(f"Caught Index Error while evaluating choice: {e}. Possibly someone retracted their vote!")
        return
    log(update.effective_user.username + " selected <" + OPTIONS[choice_index] + ">")
    response=LINES[random.randint(0,LINES.size-1)]
    if choice_index == 0:
        try:
            context.bot.send_message(
                CONFIG["CHAT_ID"],
                f"Danke {update.effective_user.mention_html()}. {response} &#128151;",
                parse_mode=ParseMode.HTML,
            )
        except requests.exceptions.NewConnectionError as e:
            log(f"Caught a NewConnectionError: {e}")
        except Exception as e:
            log(f"Caught a generic exception: {e}")
        FinalReminderTimer.stop()
        FOUND_SOMEONE = True

def send_final_warning():
    msg = "Bisher hat niemand die Tonnen rausgestellt. Vielleicht nochmal jemand jetzt fix rausflitzen? &#128536;"
    message = Bot(TOKEN).send_message(
        CONFIG["CHAT_ID"],
        f"{msg}",
        parse_mode=ParseMode.HTML
    )
    log(msg)
        
########################################################################################## MAIN ###
def main() -> None:
    global FOUND_SOMEONE

    tonnen="Müll"
    if len(sys.argv) < 2:
        log("Error. No arguments provided.")
        FinalReminderTimer.stop()
        sys.exit()
    elif sys.argv[1] == "Bio":
        tonnen="Bio- und Restmüll"
    elif sys.argv[1] == "Papier":
        tonnen="den gelber Sack und Papiermüll"

    log("Sending poll to group")
    poll_id = send_poll(tonnen)

    updater = Updater(CONFIG["TOKEN"])
    dispatcher = updater.dispatcher
    dispatcher.add_handler(PollAnswerHandler(lambda update, context: receive_poll_answer(update, context, poll_id), pass_user_data=True, pass_update_queue=True), group=1)

    updater.start_polling()

    while not FinalReminderTimer.timedOut():
        time.sleep(5)

    FOUND_SOMEONE or send_final_warning()

    updater.stop()
    FinalReminderTimer.stop()

if __name__ == '__main__':
    main()
    log("Poll successfully ended.")

########################################################################################### END ###
