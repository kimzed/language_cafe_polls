# WhatsApp Language Cafe Poll Automation

Automatically sends two polls every Monday to your Language Cafe WhatsApp group:
1. "I can help with" (languages you can teach)
2. "I want to learn" (languages you want to practice)

## Requirements

- Raspberry Pi (or any Linux server)
- Docker & Docker Compose
- WhatsApp account

## Setup

### 1. Start the WhatsApp service

```bash
docker compose up -d
```

### 2. Link your WhatsApp

Open http://your-pi-ip:3000 in a browser and scan the QR code with your phone:
- Open WhatsApp on your phone
- Go to Settings → Linked Devices → Link a Device
- Scan the QR code

### 3. Find your group ID

```bash
./find_groups.sh
```

Copy the JID of your Language Cafe group (looks like `120363xxxxx@g.us`).

### 4. Configure

```bash
cp .env.example .env
# Edit .env and set WHATSAPP_GROUP_ID
```

### 5. Test

```bash
source .env
export WHATSAPP_GROUP_ID
./send_polls.sh
```

Check your WhatsApp group for the polls!

### 6. Set up automatic Monday polls

```bash
./setup_cron.sh
```

This schedules the polls to send every Monday at 9:00 AM.

## Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Runs the WhatsApp API server |
| `send_polls.sh` | Sends the two polls |
| `find_groups.sh` | Lists groups to find the group ID |
| `setup_cron.sh` | Installs the Monday cron job |
| `.env` | Your configuration (group ID, etc.) |

## Troubleshooting

**Session expired / need to re-scan QR:**
- Open http://your-pi-ip:3000
- Scan QR code again

**Polls not sending:**
- Check logs: `docker compose logs -f`
- Verify group ID: `./find_groups.sh`
- Test manually: `./send_polls.sh`

**Check cron logs:**
```bash
tail -f /var/log/language_cafe_polls.log
```

### Instructions for the raspberry pi

```text
1. Transfer files to Pi                                                       
                                                                                
  # From your current machine                                                   
  scp docker-compose.yml send_polls.sh setup_cron.sh                            
  pi@<pi-ip>:~/language_cafe_polls/                                             
                                                                                
  2. Install Docker on the Pi                                                   
                                                                                
  # SSH into Pi                                                                 
  ssh pi@<pi-ip>                                                                
                                                                                
  # Install Docker                                                              
  curl -fsSL https://get.docker.com | sh                                        
  sudo usermod -aG docker $USER                                                 
  # Log out and back in for group changes                                       
                                                                                
  3. Start the container                                                        
                                                                                
  cd ~/language_cafe_polls                                                      
  docker compose up -d                                                          
                                                                                
  4. Link WhatsApp (headless - no screen needed)                                
                                                                                
  Since you don't have a screen, you can fetch the QR code via the API and      
  display it on your local machine:                                             
                                                                                
  # From your local machine (not the Pi), after the container is running on Pi: 
                                                                                
  # Request a new session with QR                                               
  curl -X POST -H "X-Api-Key: myapikey123" \                                    
    "http://<pi-ip>:3000/api/sessions/start" \                                  
    -H "Content-Type: application/json" \                                       
    -d '{"name": "default", "config": {}}'                                      
                                                                                
  # Get QR code as image and save it                                            
  curl -H "X-Api-Key: myapikey123" \                                            
    "http://<pi-ip>:3000/api/default/auth/qr" \                                 
    --output qr_code.png                                                        
                                                                                
  # Open it locally                                                             
  xdg-open qr_code.png  # Linux                                                 
  # or: open qr_code.png  # macOS                                               
                                                                                
  Scan that QR with your WhatsApp app (Linked Devices > Link a Device).         
                                                                                
  5. Verify connection                                                          
                                                                                
  curl -H "X-Api-Key: myapikey123" "http://<pi-ip>:3000/api/sessions"           
  # Should show status: "WORKING"                                               
                                                                                
  6. Create .env on Pi                                                          
                                                                                
  echo 'WHATSAPP_GROUP_ID=120363044435271595@g.us' > .env                       
                                                                                
  7. Set up cron for automated polls                                            
                                                                                
  ./setup_cron.sh                                                               
                                                                                
  ---                                                                           
  Important notes:                                                              
  - The WhatsApp session persists in the Docker volume, so you only need to scan
   QR once                                                                      
  - Make sure port 3000 is accessible on your Pi (firewall/router settings if   
  accessing remotely)                                                           
  - Consider changing myapikey123 to a secure key in production
```