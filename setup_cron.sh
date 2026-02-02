#!/bin/bash
#
# Set up cron job to send polls every Monday at 9:00 AM
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

# Check if .env exists
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: .env file not found at $ENV_FILE"
    echo "Create it with: echo 'WHATSAPP_GROUP_ID=120363044435271595@g.us' > $ENV_FILE"
    exit 1
fi

# Source .env and run script (log to project directory)
LOG_FILE="$SCRIPT_DIR/polls.log"
CRON_CMD="0 9 * * 1 cd $SCRIPT_DIR && source .env && ./send_polls.sh >> $LOG_FILE 2>&1"

echo "This will add the following cron job:"
echo "$CRON_CMD"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Add cron job (avoiding duplicates)
    (crontab -l 2>/dev/null | grep -v "send_polls.sh"; echo "$CRON_CMD") | crontab -
    echo "Cron job installed! Polls will be sent every Monday at 9:00 AM."
    echo ""
    echo "Current crontab:"
    crontab -l
else
    echo "Cancelled."
fi
