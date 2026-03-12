#!/bin/bash
# Multiflex SSH+WS+SSL Setup Script
# Author: YourName
# Date: 2026-03-12

# Colors for menu
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Menu function
menu() {
    clear
    echo "======================================"
    echo "        Multiflex SSH+WS+SSL Menu     "
    echo "======================================"
    echo "1) Install SSH+WS+SSL Server"
    echo "2) Install Non-TLS Server on Port 80"
    echo "3) Start All Services"
    echo "4) Stop All Services"
    echo "5) Exit"
    echo "======================================"
    read -p "Select an option [1-5]: " choice
    case $choice in
        1) install_ssl ;;
        2) install_non_tls ;;
        3) start_services ;;
        4) stop_services ;;
        5) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" ; sleep 2 ; menu ;;
    esac
}

# Install SSH + WS + SSL
install_ssl() {
    echo -e "${GREEN}Installing SSH + WS + SSL...${NC}"
    # Example: install xray/v2ray for WS+SSL
    apt update && apt install -y curl unzip
    curl -O https://raw.githubusercontent.com/yourgithubuser/yourrepo/main/install_xray.sh
    bash install_xray.sh
    echo -e "${GREEN}SSL server installed successfully!${NC}"
    sleep 2
    menu
}

# Install Non-TLS on Port 80
install_non_tls() {
    echo -e "${GREEN}Installing non-TLS server on port 80...${NC}"
    # Example: simple websocket server
    apt update && apt install -y python3 python3-pip
    pip3 install websockets
    cat << EOF > /usr/local/bin/ws_non_tls.py
#!/usr/bin/env python3
import asyncio, websockets

async def echo(websocket, path):
    async for message in websocket:
        await websocket.send(f"Echo: {message}")

async def main():
    async with websockets.serve(echo, "0.0.0.0", 80):
        await asyncio.Future()  # run forever

asyncio.run(main())
EOF
    chmod +x /usr/local/bin/ws_non_tls.py
    echo -e "${GREEN}Non-TLS WebSocket server ready on port 80${NC}"
    sleep 2
    menu
}

# Start all services
start_services() {
    echo -e "${GREEN}Starting services...${NC}"
    systemctl start ssh
    # Start non-TLS server in background
    nohup python3 /usr/local/bin/ws_non_tls.py >/dev/null 2>&1 &
    echo -e "${GREEN}All services started!${NC}"
    sleep 2
    menu
}

# Stop all services
stop_services() {
    echo -e "${RED}Stopping services...${NC}"
    systemctl stop ssh
    pkill -f ws_non_tls.py
    echo -e "${RED}All services stopped!${NC}"
    sleep 2
    menu
}

# Start menu
menu
