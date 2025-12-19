#!/bin/bash
# Lofi Stream to Kick - Simplified for isolated server
set -e

DISPLAY_NUM=97
SINK_NAME="virtual_speaker"
RESOLUTION="1280x720"
FPS=30
KICK_URL="rtmps://fa723fc1b171.global-contribute.live-video.net/app"
PAGE_URL="https://ldraney.github.io/lofi-stream-kick/"

if [ -z "$KICK_KEY" ]; then
    echo "Error: KICK_KEY environment variable not set"
    exit 1
fi

echo "Starting Lofi Stream to Kick..."

cleanup() {
    echo "Cleaning up..."
    pkill -f "Xvfb :$DISPLAY_NUM" 2>/dev/null || true
    pkill -f "openbox" 2>/dev/null || true
    pkill -f "chromium" 2>/dev/null || true
    pkill -f "ffmpeg" 2>/dev/null || true
    pulseaudio --kill 2>/dev/null || true
}
trap cleanup EXIT
cleanup
sleep 2

# Start virtual display
echo "Starting virtual display..."
Xvfb :$DISPLAY_NUM -screen 0 ${RESOLUTION}x24 &
sleep 2
export DISPLAY=:$DISPLAY_NUM

# Start window manager (required for proper window rendering)
echo "Starting window manager..."
openbox &
sleep 2

# PulseAudio setup - use config file approach
echo "Setting up PulseAudio..."
export HOME=/root
export XDG_RUNTIME_DIR=/run/user/0
mkdir -p $XDG_RUNTIME_DIR
mkdir -p /root/.config/pulse

# Create pulse config that loads null sink automatically
cat > /root/.config/pulse/default.pa << PULSECONF
.include /etc/pulse/default.pa
load-module module-null-sink sink_name=$SINK_NAME sink_properties=device.description=VirtualSpeaker
set-default-sink $SINK_NAME
PULSECONF

# Kill any existing and start fresh
pulseaudio --kill 2>/dev/null || true
sleep 2
pulseaudio --start --exit-idle-time=-1 2>&1 || true
sleep 3

# Verify sink exists with retries
echo "Verifying audio sink..."
for i in 1 2 3 4 5; do
    if pactl list sinks short 2>/dev/null | grep -q "$SINK_NAME"; then
        echo "Audio sink verified: $SINK_NAME (attempt $i)"
        break
    fi
    echo "Waiting for sink... ($i/5)"
    sleep 2
done

# Final check
if ! pactl list sinks short 2>/dev/null | grep -q "$SINK_NAME"; then
    echo "ERROR: Audio sink $SINK_NAME not found"
    pactl list sinks short 2>/dev/null || echo "Cannot list sinks"
    exit 1
fi

# Export PulseAudio server path for all subsequent commands
export PULSE_SERVER=unix:/run/user/0/pulse/native

# Verify we can access the monitor
echo "Testing audio source..."
if pactl list sources short 2>/dev/null | grep -q "${SINK_NAME}.monitor"; then
    echo "Audio monitor source verified: ${SINK_NAME}.monitor"
else
    echo "ERROR: Audio monitor source not found"
    pactl list sources short 2>/dev/null || echo "Cannot list sources"
    exit 1
fi

# Clear chromium data to avoid restore dialog
rm -rf /tmp/chromium-kick

# Start Chromium with fullscreen
echo "Starting Chromium..."
PULSE_SINK=$SINK_NAME chromium-browser \
    --no-sandbox \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-restore-session-state \
    --disable-features=TranslateUI,InfiniteSessionRestore \
    --hide-crash-restore-bubble \
    --noerrdialogs \
    --user-data-dir=/tmp/chromium-kick \
    --start-fullscreen \
    --autoplay-policy=no-user-gesture-required \
    --window-size=1280,720 \
    --window-position=0,0 \
    "$PAGE_URL" &
CHROME_PID=$!

echo "Waiting for page to load..."
sleep 8

# Start FFmpeg stream
echo "Starting FFmpeg stream..."
echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
pactl list sinks short 2>/dev/null || echo "Warning: Cannot list sinks"
ffmpeg \
    -thread_queue_size 1024 \
    -f x11grab \
    -video_size $RESOLUTION \
    -framerate $FPS \
    -draw_mouse 0 \
    -i :$DISPLAY_NUM \
    -thread_queue_size 1024 \
    -f pulse \
    -i ${SINK_NAME}.monitor \
    -c:v libx264 \
    -preset ultrafast \
    -tune zerolatency \
    -b:v 6000k \
    -maxrate 6000k \
    -bufsize 12000k \
    -pix_fmt yuv420p \
    -g 60 \
    -c:a aac \
    -b:a 160k \
    -ar 44100 \
    -flvflags no_duration_filesize \
    -f flv "${KICK_URL}/${KICK_KEY}"
