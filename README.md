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

## Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | WhatsApp API server |
| `send_polls.sh` | Sends the two polls |
| `find_groups.sh` | Lists groups to find group ID |
| `setup_cron.sh` | Installs Monday cron job |
| `.env` | Configuration (group ID) |

## Troubleshooting

- **Session expired:** Re-scan QR at `http://your-pi-ip:3000`
- **Polls not sending:** Check logs with `docker compose logs -f`, verify group ID with `./find_groups.sh`
- **Cron logs:** `tail -f /var/log/language_cafe_polls.log`

## Context

Built to automate weekly poll creation for a language exchange meetup group, replacing manual poll creation in WhatsApp.
