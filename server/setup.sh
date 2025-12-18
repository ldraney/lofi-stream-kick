#!/bin/bash
# Setup script for lofi-stream-kick on VPS

set -e

echo "Setting up lofi-stream-kick..."

# Install dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y xvfb chromium-browser ffmpeg pulseaudio xdotool curl jq

# Create directory
echo "Creating /opt/lofi-stream-kick..."
mkdir -p /opt/lofi-stream-kick

# Copy scripts
echo "Copying scripts..."
cp stream.sh /opt/lofi-stream-kick/
cp health-check.sh /opt/lofi-stream-kick/
chmod +x /opt/lofi-stream-kick/*.sh

# Install systemd service
echo "Installing systemd service..."
cp lofi-stream-kick.service /etc/systemd/system/
systemctl daemon-reload

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit /etc/systemd/system/lofi-stream-kick.service"
echo "   Change: Environment=KICK_KEY=YOUR_STREAM_KEY_HERE"
echo ""
echo "2. Get your Kick stream key from:"
echo "   https://kick.com -> Creator Dashboard -> Settings -> Stream"
echo ""
echo "3. Enable and start the service:"
echo "   systemctl enable lofi-stream-kick"
echo "   systemctl start lofi-stream-kick"
echo ""
echo "4. Check status:"
echo "   systemctl status lofi-stream-kick"
echo "   journalctl -u lofi-stream-kick -f"
