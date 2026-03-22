# Language Cafe Polls

Automated WhatsApp poll scheduling for a language exchange group.

## Overview

A lightweight automation that sends two weekly polls to a WhatsApp group every Monday: "I can help with" (languages you can teach) and "I want to learn" (languages you want to practice). Runs on a Raspberry Pi using Docker and cron.

## Tech Stack

- **WhatsApp API:** WAHA (WhatsApp HTTP API) via Docker
- **Scheduling:** Cron
- **Infrastructure:** Raspberry Pi / any Linux server
- **Containerization:** Docker Compose

## Setup

```bash
# 1. Start WhatsApp API
docker compose up -d

# 2. Link WhatsApp — scan QR at http://your-pi-ip:3000
#    Log in with admin / admin
#    WhatsApp → Settings → Linked Devices → Link a Device

# 3. Find your group ID
./find_groups.sh

# 4. Configure
cp .env.example .env
# Set WHATSAPP_GROUP_ID in .env

# 5. Test
source .env && export WHATSAPP_GROUP_ID && ./send_polls.sh

# 6. Schedule Monday polls (9:00 AM)
./setup_cron.sh
```

### Headless Setup (no browser on the Pi)

If running Raspberry Pi OS Lite or another headless system, you can grab the QR code via the API:

```bash
# Start a session
curl -X POST http://localhost:3000/api/sessions/start \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: myapikey123" \
  -d '{"name": "default"}'

# Wait a few seconds, then grab the QR screenshot
curl http://localhost:3000/api/screenshot?session=default \
  -H "X-Api-Key: myapikey123" \
  --output /tmp/qr.png

# Copy to your laptop and scan it
scp user@pi-ip:/tmp/qr.png ~/Downloads/qr.png
```

### Raspberry Pi / ARM64 Note

The default `waha:latest` image does not support ARM64. The `docker-compose.yml` uses `devlikeapro/waha:arm` which provides ARM64 support.

## Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | WhatsApp API server |
| `send_polls.sh` | Sends the two polls |
| `find_groups.sh` | Lists groups to find group ID |
| `setup_cron.sh` | Installs Monday cron job |
| `.env` | Configuration (group ID) |

## Troubleshooting

- **Session expired:** Re-scan QR at `http://your-pi-ip:3000` (or use the headless QR method above)
- **Polls not sending:** Check logs with `docker compose logs -f`, verify group ID with `./find_groups.sh`
- **Cron logs:** `tail -f /var/log/language_cafe_polls.log`

## Context

Built to automate weekly poll creation for a language exchange meetup group, replacing manual poll creation in WhatsApp.
