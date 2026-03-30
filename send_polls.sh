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

# Ensure WAHA session is running, restart if needed
SESSION_STATUS=$(curl -s -H "X-Api-Key: $API_KEY" "$API_URL/api/sessions/default" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','UNKNOWN'))")
echo "Session status: $SESSION_STATUS"

if [[ "$SESSION_STATUS" != "WORKING" ]]; then
    echo "Session not working, attempting to start..."
    curl -s -X POST -H "Content-Type: application/json" -H "X-Api-Key: $API_KEY" "$API_URL/api/sessions/default/start" > /dev/null

    # Wait up to 120s for session to become WORKING
    for i in $(seq 1 12); do
        sleep 10
        SESSION_STATUS=$(curl -s -H "X-Api-Key: $API_KEY" "$API_URL/api/sessions/default" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','UNKNOWN'))")
        echo "  Attempt $i: status=$SESSION_STATUS"
        if [[ "$SESSION_STATUS" == "WORKING" ]]; then
            break
        fi
    done

    if [[ "$SESSION_STATUS" != "WORKING" ]]; then
        echo "Error: Session failed to start after 120s (status: $SESSION_STATUS)"
        exit 1
    fi
fi

LANGUAGES='["Dutch", "English", "German", "French", "Spanish", "Italian", "Farsi", "Chinese", "Turkish", "Japanese", "Swahili", "Other"]'

echo "Sending poll 1: I can help with..."
RESPONSE1=$(curl -s -X POST "$API_URL/api/sendPoll" \
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
    }")
echo "$RESPONSE1"

if echo "$RESPONSE1" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' not in d else 1)" 2>/dev/null; then
    echo "Poll 1 sent successfully"
else
    echo "Error: Poll 1 failed!"
    exit 1
fi

sleep 5

echo "Sending poll 2: I want to learn..."
RESPONSE2=$(curl -s -X POST "$API_URL/api/sendPoll" \
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
    }")
echo "$RESPONSE2"

if echo "$RESPONSE2" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' not in d else 1)" 2>/dev/null; then
    echo "Poll 2 sent successfully"
else
    echo "Error: Poll 2 failed!"
    exit 1
fi

echo "Done! Both polls sent."
