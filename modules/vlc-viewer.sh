set -euo pipefail

RTSP_URL="rtsp://WlsIqjkVvhFx2FLEyKKe9zvB6qy7UVR4:fKAjwOwi7ozV705EBfGTI@test.rtsp.stream/pattern"
LOG_DIR="${HOME}/coffee-screen-viewer-logs"
mkdir -p "$LOG_DIR"
VLC_LOG="$LOG_DIR/vlc.log"

export QT_QPA_PLATFORM=wayland
vlc --fullscreen --avcodec-hw=any "$RTSP_URL" >> "$VLC_LOG" 2>&1
