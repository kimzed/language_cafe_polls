#!/bin/bash
#
# List all WhatsApp groups to find the group ID
#

API_URL="${WHATSAPP_API_URL:-http://localhost:3000}"
AUTH="${WHATSAPP_BASIC_AUTH:-}"

AUTH_HEADER=""
if [[ -n "$AUTH" ]]; then
    AUTH_HEADER="-u $AUTH"
fi

echo "Fetching WhatsApp groups..."
echo ""

curl -s "$API_URL/group" $AUTH_HEADER | python3 -m json.tool 2>/dev/null || \
curl -s "$API_URL/group" $AUTH_HEADER

echo ""
echo "Use the 'JID' field (ending in @g.us) as your WHATSAPP_GROUP_ID"
