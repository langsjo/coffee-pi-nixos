set -euo pipefail

RTSP_URL="rtsp://WlsIqjkVvhFx2FLEyKKe9zvB6qy7UVR4:fKAjwOwi7ozV705EBfGTI@test.rtsp.stream/pattern"
LOG_DIR="${HOME}/coffee-screen-viewer-logs"
mkdir -p "$LOG_DIR"
GST_LOG="$LOG_DIR/gstreamer.log"

# Buffer targets for short network interruptions.
LATENCY_MS="${LATENCY_MS:-5000}"
JITTER_BUFFER_MS="${JITTER_BUFFER_MS:-90000}"

choose_decoder() {
    if gst-inspect-1.0 v4l2h264dec >/dev/null 2>&1; then
        echo "v4l2h264dec capture-io-mode=dmabuf-import ! videoconvert"
        return
    fi
    if gst-inspect-1.0 avdec_h264 >/dev/null 2>&1; then
        echo "avdec_h264 max-threads=2 ! videoconvert"
        return
    fi
    echo ""
}

choose_video_sink() {
    if gst-inspect-1.0 waylandsink >/dev/null 2>&1; then
        echo "waylandsink sync=false fullscreen=true"
        return
    fi
    if gst-inspect-1.0 autovideosink >/dev/null 2>&1; then
        echo "autovideosink sync=false"
        return
    fi
    echo ""
}

DECODER="$(choose_decoder)"
VIDEO_SINK="$(choose_video_sink)"

if [ -z "$DECODER" ] || [ -z "$VIDEO_SINK" ]; then
    echo "[$(date)] Missing required GStreamer plugins (decoder or video sink)." &>> "$GST_LOG"
    echo "[$(date)] Decoder='$DECODER' Sink='$VIDEO_SINK'" &>> "$GST_LOG"
    exit 1
fi

{
    echo "[$(date)] Starting coffee-screen viewer loop for ${RTSP_URL}...";
    echo "[$(date)] Decoder: ${DECODER}";
    echo "[$(date)] Video sink: ${VIDEO_SINK}";
    echo "[$(date)] RTSP latency: ${LATENCY_MS}ms, jitter buffer: ${JITTER_BUFFER_MS}ms";
} &>> "$GST_LOG"

while true; do
    echo "[$(date)] Launching GStreamer pipeline..." &>> "$GST_LOG"

    # shellcheck disable=SC2086
    gst-launch-1.0 \
        rtspsrc \
            location="${RTSP_URL}" \
            protocols=tcp \
            timeout=5000000 \
            tcp-timeout=5000000 \
            do-retransmission=true \
            latency="${LATENCY_MS}" \
            drop-on-latency=false \
            ! rtph264depay \
            ! h264parse config-interval=-1 disable-passthrough=true \
            ! queue max-size-time="${JITTER_BUFFER_MS}000000" max-size-bytes=0 max-size-buffers=0 leaky=downstream \
            ! ${DECODER} \
            ! queue max-size-time=2000000000 max-size-bytes=0 max-size-buffers=0 leaky=downstream \
            ! ${VIDEO_SINK} \
        >>"$GST_LOG" 2>&1 || true

    echo "[$(date)] Pipeline exited, restarting in 3 seconds..." &>> "$GST_LOG"
    sleep 3
done
