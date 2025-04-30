## Dobby - the house-elf

This is a collection of scripts that use the telegram api to create helpful bots. These bots are best triggered using cronjobs to send customized reminders or polls! Feel free to use the scripts straight away or modify them to suit your needs.

**Attention:** If you fork this directory, make sure to never push any file containing your token or id!

### General Setup
0. Clone this repo to your desired location.
1. [Obtain your bot token from telegram](https://core.telegram.org/bots/tutorial#obtain-your-bot-token)
2. Add your bot to a desired chat 
3. Get the chat id as follows:<br>
   1. Open a new window in privacy mode in your prefered browser. This ensures that your token is not stored in the browser history.<br>
   2. Copy this URL into your opened window: `https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates`<br>
   3. Replace `YOUR_BOT_TOKEN` with your actual token and press Enter<br>
   4. In the output find the `chat` key and look for an `id` field just below. This will only work, once you have added your bot to a chat.<br>
4. Create a `config.txt` file at the root of this repo and add your bots token and the chat id as [shown below](#config)
6. Run any of the scripts from the command line
7. To repeatedly run script, you can setup a cronjob
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

### Config
Please create this file manually. I did not want to provide an example to avoid accidental commit of sensitive data. Create this file (`config.txt`) at the root of this directory and add your bots id and the chat id as follows. You can also store several different bots and chats, name them as you please and reference them in any of the scripts you use.

```bash
TOKEN=<your_bot_token>
CHAT_ID=<your_chat_id>
```
