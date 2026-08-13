#!/bin/sh
# Minimal HA-Chumby boot confirmation screen.

APP_DIR="$(dirname "$0")"
IMAGE="$APP_DIR/boot-screen.rgb565"
LOG="/tmp/ha-chumby.log"

write_screen() {
    fb="$1"
    if [ -e "$fb" ] && [ -w "$fb" ] && [ -r "$IMAGE" ]; then
        cat "$IMAGE" > "$fb"
        echo "HA-Chumby boot screen written to $fb" >> "$LOG"
        return 0
    fi
    return 1
}

write_screen /dev/fb0 || write_screen /dev/fb || echo "No writable framebuffer found" >> "$LOG"

# Keep the process alive so the boot proof remains easy to find in ps/logs.
while true; do
    sleep 3600
done