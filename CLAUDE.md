# lofi-stream-kick

24/7 lofi stream to Kick with an arcade/retro gaming theme.

**Status:** ✅ Live at https://kick.com/skywalker939

## Quick Reference

```bash
# SSH to production server
ssh -i ~/api-secrets/hetzner-server/id_ed25519 root@46.62.216.25

# Check stream status
ssh root@46.62.216.25 'systemctl status lofi-stream'

# View logs
ssh root@46.62.216.25 'journalctl -u lofi-stream -f'

# Take screenshot
ssh root@46.62.216.25 'DISPLAY=:97 import -window root /tmp/screen.png'
scp root@46.62.216.25:/tmp/screen.png .

# Local development - open in browser
cd docs && python3 -m http.server 8080
```

## Secrets

```bash
# Stream key
cat ~/api-secrets/lofi-stream/platforms/kick.env

# SSH key for servers
~/api-secrets/hetzner-server/id_ed25519
```

## Architecture

```
GitHub Pages (docs/index.html)
        ↓ (loaded by)
Chromium on Hetzner CPX11 (DISPLAY :97)
        ↓ (captured by)
FFmpeg → PulseAudio (virtual_speaker) → RTMPS → Kick
```

## Theme: Arcade/Retro Gaming

Visual elements:
- Dark purple/black background with CRT scanlines
- Retro arcade cabinet with glowing CRT monitor
- Animated pixel art waveform visualizer
- Neon "INSERT COIN" sign with glow animation
- Checkered arcade carpet floor
- Joystick and coin slot decorations

Color palette:
- Neon pink: #ff00ff
- Cyan: #00ffff
- Purple: #9900ff
- Dark purple: #1a0a2e

## Audio: Chiptune Lofi

- Square/triangle wave oscillators for 8-bit aesthetic
- Chord progression: C → F → G → Am (I-IV-V-vi)
- Fast arpeggios cycling through chord tones
- Square wave sub-bass
- Low arcade hum ambient
- Vinyl crackle for lofi authenticity

## Server Configuration

| Setting | Value |
|---------|-------|
| Server IP | 46.62.216.25 |
| Display | :97 |
| Audio Sink | virtual_speaker |
| Window Manager | openbox |
| RTMP URL | rtmps://fa723fc1b171.global-contribute.live-video.net/app |
| Video Bitrate | 6000 kbps |
| Audio Bitrate | 160 kbps |
| Resolution | 1280x720 @ 30fps |

## File Structure

```
lofi-stream-kick/
├── CLAUDE.md           # This file
├── README.md           # Public readme
├── docs/
│   ├── index.html      # Arcade visuals + Web Audio
│   └── style.css       # Neon retro styling
└── server/
    ├── stream.sh       # Main streaming script
    └── lofi-stream-kick.service # systemd unit template
```

## Deployment

Infrastructure is managed via [lofi-stream-infra](https://github.com/ldraney/lofi-stream-infra).

### Deploy with Ansible (recommended)

```bash
cd ~/lofi-stream-infra/ansible
ansible-playbook playbooks/deploy.yml -l lofi-kick
```

### Manual deployment

```bash
# On VPS (46.62.216.25)
cd /opt
git clone https://github.com/ldraney/lofi-stream-kick.git
chmod +x /opt/lofi-stream-kick/server/stream.sh

# Create systemd service with stream key
cat > /etc/systemd/system/lofi-stream.service << EOF
[Unit]
Description=Lofi Stream to Kick
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/lofi-stream-kick/server
Environment=KICK_KEY=your_stream_key_here
ExecStart=/opt/lofi-stream-kick/server/stream.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable lofi-stream
systemctl start lofi-stream
```

## Stream Script Key Features

The `server/stream.sh` script handles:
1. **Xvfb** - Virtual display :97
2. **Openbox** - Window manager (required for Chromium rendering)
3. **PulseAudio** - Audio sink setup via config file approach
4. **Chromium** - Loads the GitHub Pages visualization
5. **FFmpeg** - Captures display + audio, streams to Kick

Key reliability improvements:
- PulseAudio config file loads sink at startup (more reliable than pactl)
- Retry loops for audio sink verification
- Chromium flags to suppress restore dialogs
- Clears user data dir on restart to avoid session issues

## Troubleshooting

### No audio in stream
```bash
# Check if audio sink exists
ssh root@46.62.216.25 'pactl list sinks short'

# Check if Chromium is playing to the sink
ssh root@46.62.216.25 'pactl list sink-inputs short'
```

### Black screen / no video
```bash
# Check all processes running
ssh root@46.62.216.25 'ps aux | grep -E "(Xvfb|chromium|openbox|ffmpeg)"'

# Take screenshot to debug
ssh root@46.62.216.25 'DISPLAY=:97 import -window root /tmp/debug.png'
```

### Stream disconnects
```bash
# Check logs for FFmpeg errors
ssh root@46.62.216.25 'journalctl -u lofi-stream -n 100 --no-pager | grep -i error'

# Restart the service
ssh root@46.62.216.25 'systemctl restart lofi-stream'
```

## Related Repos

- [lofi-stream-infra](https://github.com/ldraney/lofi-stream-infra) - Terraform + Ansible
- [lofi-stream-docs](https://github.com/ldraney/lofi-stream-docs) - Documentation hub
- [lofi-stream-youtube](https://github.com/ldraney/lofi-stream-youtube) - Night city theme
- [lofi-stream-twitch](https://github.com/ldraney/lofi-stream-twitch) - Coffee shop theme
