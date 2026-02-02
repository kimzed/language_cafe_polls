#!/bin/bash
#
# Send Language Cafe polls to WhatsApp group
# Called by cron every Monday
#

set -euo pipefail

# Configuration - edit these or set as environment variables
API_URL="${WHATSAPP_API_URL:-http://localhost:3000}"
GROUP_ID="${WHATSAPP_GROUP_ID:-}"  # Format: 120363xxxxx@g.us
API_KEY="${WHATSAPP_API_KEY:-myapikey123}"

if [[ -z "$GROUP_ID" ]]; then
    echo "Error: WHATSAPP_GROUP_ID not set"
    exit 1
fi

LANGUAGES='["Dutch", "English", "German", "French", "Spanish", "Italian", "Farsi", "Chinese", "Turkish", "Japanese", "Swahili", "Other"]'

echo "Sending poll 1: I can help with..."
curl -s -X POST "$API_URL/api/sendPoll" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $API_KEY" \
    -d "{
        \"session\": \"default\",
        \"chatId\": \"$GROUP_ID\",
        \"poll\": {
            \"name\": \"Language cafe today 20:00, I can help with\",
            \"options\": $LANGUAGES,
            \"multipleAnswers\": true
        }
    }"
echo ""

echo "Sending poll 2: I want to learn..."
curl -s -X POST "$API_URL/api/sendPoll" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $API_KEY" \
    -d "{
        \"session\": \"default\",
        \"chatId\": \"$GROUP_ID\",
        \"poll\": {
            \"name\": \"Language cafe today 20:00, I want to learn\",
            \"options\": $LANGUAGES,
            \"multipleAnswers\": true
        }
    }"
echo ""

echo "Done! Both polls sent."
