#!/bin/bash
set -e

echo "=== Starting SSH service ==="
service ssh start

# Check Ngrok token
if [ -z "$NGROK_AUTH_TOKEN" ]; then
  echo "Error: NGROK_AUTH_TOKEN is not set."
  echo "Set it as an environment variable on your platform (e.g. Railway, Render, etc.)."
  exit 1
fi

# Configure Ngrok
ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

echo "=== Starting Ngrok TCP tunnel for SSH (port 22) ==="
ngrok tcp 22 --region ap --log=stdout > /tmp/ngrok.log 2>&1 &

# Wait for Ngrok to start
sleep 5

# Get tunnel URL
TUNNEL_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -Eo "tcp://[0-9a-zA-Z\.\-]+:[0-9]+" | head -n 1)

echo ""
if [ -n "$TUNNEL_URL" ]; then
  HOST_PORT=$(echo "$TUNNEL_URL" | sed 's#tcp://##')
  echo "=== SSH tunnel is ready ==="
  echo "Ngrok TCP: $TUNNEL_URL"
  echo ""
  echo "Connect using:"
  echo "  ssh ubuntu@$HOST_PORT"
  echo ""
  echo "Default username: ubuntu"
  echo "Default password: ubuntu"
else
  echo "Failed to retrieve Ngrok tunnel. Check /tmp/ngrok.log for details."
fi

echo ""
echo "=== Keeping container alive on port 8080 ==="
python3 -m http.server 8080
