set -euo pipefail

RTSP_URL="rtsp://WlsIqjkVvhFx2FLEyKKe9zvB6qy7UVR4:fKAjwOwi7ozV705EBfGTI@test.rtsp.stream/pattern"
LOG_DIR="${HOME}/coffee-screen-viewer-logs"
mkdir -p "$LOG_DIR"
MPV_LOG="$LOG_DIR/mpv.log"

detect_hwdec_mode() {
    local hwdec_help
    local mode
    if ! hwdec_help="$(mpv --no-config --hwdec=help 2>/dev/null)"; then
        echo "auto"
        return
    fi

    for mode in \
        v4l2m2m-copy \
        v4l2m2m \
        vaapi-copy \
        vaapi \
        auto-copy-safe \
        auto-safe \
        auto
    do
        if printf '%s\n' "$hwdec_help" | grep -Eiq "^[[:space:]]*${mode}[[:space:]]*$"; then
            echo "$mode"
            return
        fi
    done

    echo "no"
}

HWDEC_MODE="$(detect_hwdec_mode)"

echo "[$(date)] Starting coffee-screen viewer loop for ${RTSP_URL}..." >&2
echo "[$(date)] Selected mpv hwdec mode: ${HWDEC_MODE}" >&2
while true; do
    echo "[$(date)] Launching mpv..." >&2

    mpv \
        --no-config \
        --rtsp-transport=tcp \
        --geometry=100%x100% \
        --fs \
        --no-border \
        --gpu-context=wayland \
        --gpu-api=opengl \
        --opengl-es=yes \
        --vo=gpu \
        --ontop \
        --no-audio \
        --hwdec="$HWDEC_MODE" \
        --cache=no \
        --demuxer-lavf-o=fflags=nobuffer \
        --framedrop=vo \
        --force-window=immediate \
        --quiet \
        "$RTSP_URL" >>"$MPV_LOG" 2>&1 || true

    echo "[$(date)] mpv exited, restarting in 5 seconds..." >&2
    sleep 5
done
