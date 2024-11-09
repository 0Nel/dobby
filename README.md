## Dobby - the house-elf

This is a collection of scripts that use the telegram api to create helpful bots. These bots are best triggered using cronjobs to send customized reminders or polls! Feel free to use the scripts straight away or modify them to suit your needs.

**Attention:** If you fork this directory, make sure to never push any file containing your token or id!

### Setup
0. Clone this repo to your desired location.
1. [Obtain your bot token from telegram](https://core.telegram.org/bots/tutorial#obtain-your-bot-token)
2. Add your bot to a desired chat 
3. Get the chat id as follows:<br>
   1. Open a new window in privacy mode in your prefered browser. This ensures that your token is not stored in the browser history.<br>
   2. Copy this URL into your opened window: `https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates`<br>
   3. Replace `YOUR_BOT_TOKEN` with your actual token and press Enter<br>
   4. In the output find the `chat` key and look for an `id` field just below. This will only work, once you have added your bot to a chat.<br>
4. Copy your bots token and the chat id into the `config.txt`
5. Run any of the top level scripts from the command line
6. To repeatedly run script, you can setup a cronjob
   1. On ubuntu, type: `crontab -e`
   2. Add a new line in the following format: crontime command path_to_script >> path_of_logfile 2>&1
   3. For example: `20 16 * * 02 /bin/bash ~/dobby/send_garbage_reminder.bash >> ~/dobby/garbage_poll.log 2>&1`
   4. This would run the script on every Tuesday at 16:20. Adjust the time definition as needed. Get some help [here](https://crontab.guru/).
   5. Adjust the path to the script and log file
   6. Save and exit the file

### Structure
| name | type | annotation |
|-|-|-|
| send_garbage_reminder.bash | file | sends a weekly poll to remind taking out the garbage |
| config.txt | file | store your credentials |
| modules | directory | helper scripts | 
| data | directory | stores text files with strings or links for random response customizations |
