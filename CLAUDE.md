# lofi-stream-kick

24/7 lofi stream to Kick with an arcade/retro gaming theme.

## Quick Reference

```bash
# Local development - open in browser
cd docs && python3 -m http.server 8080

# Deploy to dev server for testing
make deploy-dev

# Check production status
ssh root@135.181.150.82 'systemctl status lofi-stream-kick'
```

## Architecture

```
GitHub Pages (static HTML/CSS/JS)
        ↓ (rendered by)
Chromium on Hetzner VPS (:97)
        ↓ (captured by)
FFmpeg → RTMPS → Kick
```

## Theme: Arcade/Retro Gaming

Visual elements:
- Dark purple/black background with CRT scanlines overlay
- Retro arcade cabinet with glowing CRT monitor
- Animated pixel art waveform visualizer on screen
- Neon "INSERT COIN" sign with glow animation
- Checkered arcade carpet floor
- Joystick and coin slot decorations

Color palette:
- Neon pink: #ff00ff
- Cyan: #00ffff
- Purple: #9900ff
- Dark purple: #1a0a2e
- Black: #0a0a0a

## Audio: Chiptune Lofi

- Square/triangle wave oscillators for 8-bit aesthetic
- Chord progression: C → F → G → Am (I-IV-V-vi)
- Fast arpeggios cycling through chord tones
- Square wave sub-bass
- Low arcade hum ambient
- Occasional retro "bleep" sound effects
- Vinyl crackle for lofi authenticity

## Server Configuration

| Setting | Value |
|---------|-------|
| Display | :97 |
| Audio Sink | kick_speaker |
| User Data Dir | /tmp/chromium-kick |
| RTMP URL | rtmps://fa723fc1b171.global-contribute.live-video.net/app |
| Video Bitrate | 6000 kbps |
| Audio Bitrate | 160 kbps |
| Resolution | 1280x720 @ 30fps |

## File Structure

```
lofi-stream-kick/
├── CLAUDE.md           # This file
├── README.md           # Public readme
├── Makefile            # Dev server deployment
├── docs/
│   ├── index.html      # Arcade visuals + Web Audio
│   └── style.css       # Neon retro styling
└── server/
    ├── stream.sh       # Main streaming script
    ├── setup.sh        # Server setup automation
    ├── health-check.sh # Monitoring script
    └── lofi-stream-kick.service # systemd unit
```

## Deployment

### First-time setup on production server:

```bash
# On VPS (135.181.150.82)
cd /opt
git clone https://github.com/ldraney/lofi-stream-kick.git
cd lofi-stream-kick/server
chmod +x *.sh
./setup.sh

# Edit service file to add stream key
sudo nano /etc/systemd/system/lofi-stream-kick.service
# Change: Environment=KICK_KEY=YOUR_STREAM_KEY_HERE

# Start the service
sudo systemctl daemon-reload
sudo systemctl enable lofi-stream-kick
sudo systemctl start lofi-stream-kick
```

### Get Kick Stream Key:

1. Go to https://kick.com
2. Creator Dashboard > Settings > Stream
3. Copy the Stream Key

## Troubleshooting

### No audio in stream
- Check if PulseAudio sink exists: `pactl list sinks | grep kick`
- Verify Chromium audio routing: `pactl list sink-inputs`
- Ensure PULSE_SERVER is exported in stream.sh

### Stream not connecting
- Kick uses RTMPS (TLS) - ensure ffmpeg supports it
- Verify stream key is correct and not expired
- Check Kick dashboard for any account issues

### Video quality issues
- Kick supports up to 8000 kbps - can increase if needed
- Check CPU usage: `htop`
- Verify ffmpeg is using hardware acceleration if available

## Related Repos

- [lofi-stream-youtube](https://github.com/ldraney/lofi-stream-youtube) - Night city theme
- [lofi-stream-twitch](https://github.com/ldraney/lofi-stream-twitch) - Coffee shop theme
- [lofi-stream-docs](https://github.com/ldraney/lofi-stream-docs) - Documentation hub
