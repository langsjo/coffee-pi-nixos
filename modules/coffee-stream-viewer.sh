set -euo pipefail

RTSP_URL="rtsp://WlsIqjkVvhFx2FLEyKKe9zvB6qy7UVR4:fKAjwOwi7ozV705EBfGTI@test.rtsp.stream/pattern"
LOG_DIR="${HOME}/coffee-screen-viewer-logs"
mkdir -p "$LOG_DIR"
MPV_LOG="$LOG_DIR/mpv.log"

echo "[$(date)] Starting coffee-screen viewer loop for ${RTSP_URL}..." >&2
while true; do
    echo "[$(date)] Launching mpv..." >&2

    mpv \
        --no-config \
        --rtsp-transport=tcp \
        --profile=low-latency \
        --geometry=100%x100% \
        --fs \
        --no-border \
        --gpu-context=wayland \
        --gpu-api=opengl \
        --vo=gpu \
        --ontop \
        --no-audio \
        --hwdec=drm-copy \
        --cache=no \
        --demuxer-lavf-o=fflags=nobuffer \
        --framedrop=vo \
        --force-window=immediate \
        --quiet \
        "$RTSP_URL" >>"$MPV_LOG" 2>&1 || true

    echo "[$(date)] mpv exited, restarting in 5 seconds..." >&2
    sleep 5
done
