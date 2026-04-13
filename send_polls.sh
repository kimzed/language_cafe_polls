#!/bin/bash
#
# Send Language Cafe polls to WhatsApp group
# Called by cron every Monday
#

set -euo pipefail

# Configuration - edit these or set as environment variables
API_URL="${WHATSAPP_API_URL:-http://localhost:3001}"
GROUP_ID="${WHATSAPP_GROUP_ID:-}"  # Format: 120363xxxxx@g.us

if [[ -z "$GROUP_ID" ]]; then
    echo "Error: WHATSAPP_GROUP_ID not set"
    exit 1
fi

# Check whatsapp-sender health
HEALTH=$(curl -s "$API_URL/health")
WA_STATUS=$(echo "$HEALTH" | python3 -c "import sys,json; print(json.load(sys.stdin).get('whatsapp','unknown'))")
echo "WhatsApp status: $WA_STATUS"

if [[ "$WA_STATUS" != "connected" ]]; then
    echo "Error: WhatsApp not connected (status: $WA_STATUS)"
    exit 1
fi

LANGUAGES='["Dutch", "English", "German", "French", "Spanish", "Italian", "Farsi", "Chinese", "Turkish", "Japanese", "Swahili", "Other"]'

echo "Sending poll 1: I can help with..."
RESPONSE1=$(curl -s -X POST "$API_URL/send/poll" \
    -H "Content-Type: application/json" \
    -d "{
        \"chatId\": \"$GROUP_ID\",
        \"name\": \"Language cafe today 20:00, I can help with\",
        \"options\": $LANGUAGES,
        \"selectableCount\": 0
    }")
echo "$RESPONSE1"

if echo "$RESPONSE1" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('ok') else 1)" 2>/dev/null; then
    echo "Poll 1 sent successfully"
else
    echo "Error: Poll 1 failed!"
    exit 1
fi

sleep 5

echo "Sending poll 2: I want to learn..."
RESPONSE2=$(curl -s -X POST "$API_URL/send/poll" \
    -H "Content-Type: application/json" \
    -d "{
        \"chatId\": \"$GROUP_ID\",
        \"name\": \"Language cafe today 20:00, I want to learn\",
        \"options\": $LANGUAGES,
        \"selectableCount\": 0
    }")
echo "$RESPONSE2"

if echo "$RESPONSE2" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('ok') else 1)" 2>/dev/null; then
    echo "Poll 2 sent successfully"
else
    echo "Error: Poll 2 failed!"
    exit 1
fi

echo "Done! Both polls sent."
