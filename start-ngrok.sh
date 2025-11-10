#!/bin/bash
set -e

echo "=== Starting SSH service ==="
service ssh start

if [ -z "$NGROK_AUTH_TOKEN" ]; then
    echo "Error: NGROK_AUTH_TOKEN is not set."
    echo "Set it as an environment variable on your platform."
    exit 1
fi

# Configure Ngrok
ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

echo "=== Starting Ngrok TCP tunnel for SSH (port 22) ==="
ngrok tcp 22 --region ap --log=stdout > /tmp/ngrok-ssh.log 2>&1 &
sleep 5

# Optional: start an HTTP tunnel for a web panel or app (default port 8080)
WEB_PORT="${WEB_PORT:-8080}"
echo "=== Starting Ngrok HTTP tunnel for port $WEB_PORT (optional) ==="
ngrok http "$WEB_PORT" --region ap --log=stdout > /tmp/ngrok-http.log 2>&1 &
sleep 5

# Fetch and print tunnel info
echo "=== Ngrok Tunnels ==="
TUNNELS_JSON=$(curl -s http://127.0.0.1:4040/api/tunnels || true)

SSH_TUNNEL=$(echo "$TUNNELS_JSON" | grep -Eo "tcp://[0-9a-zA-Z\.\-]+:[0-9]+")
HTTP_TUNNEL=$(echo "$TUNNELS_JSON" | grep -Eo "https://[0-9a-zA-Z\.\-]+:[0-9]+" | head -n 1)

if [ -n "$SSH_TUNNEL" ]; then
    echo ""
    echo "SSH tunnel:"
    echo "  $SSH_TUNNEL"
    echo ""
    echo "Connect using:"
    echo "  ssh ubuntu@$(echo "$SSH_TUNNEL" | sed 's#tcp://##')"
else
    echo "No SSH tunnel detected. Check /tmp/ngrok-ssh.log."
fi

if [ -n "$HTTP_TUNNEL" ]; then
    echo ""
    echo "HTTP tunnel (port $WEB_PORT):"
    echo "  $HTTP_TUNNEL"
fi

echo ""
echo "=== Keeping container alive on port 8080 ==="
python3 -m http.server 8080
