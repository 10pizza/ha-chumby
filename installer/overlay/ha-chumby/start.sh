#!/bin/sh
# Finite HA-Chumby boot splash with original Chumby runtime hand-off.

APP_DIR="$(dirname "$0")"
IMAGE="$APP_DIR/boot-screen.rgb565"
LOG="/tmp/ha-chumby.log"
USB_DIAGNOSTICS="$APP_DIR/boot-diagnostics.txt"
USB_ROOT="/mnt/usb"
ZURK_ORIGINAL="$USB_ROOT/debugchumby.zurk-original"
ZURK_STARTUP="$USB_ROOT/lighty/startup.sh"
FRAMEBUFFER=""
SPLASH_SECONDS=3

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') start.sh: $*" >> "$LOG"
}

section() {
    echo "" >> "$LOG"
    echo "===== $* =====" >> "$LOG"
}

run_cmd() {
    label="$1"
    shift
    echo "" >> "$LOG"
    echo "--- $label ---" >> "$LOG"
    "$@" >> "$LOG" 2>&1
    status=$?
    echo "--- exit $status: $label ---" >> "$LOG"
    return $status
}

run_shell() {
    label="$1"
    command_text="$2"
    echo "" >> "$LOG"
    echo "--- $label ---" >> "$LOG"
    sh -c "$command_text" >> "$LOG" 2>&1
    status=$?
    echo "--- exit $status: $label ---" >> "$LOG"
    return $status
}

copy_diagnostics_to_usb() {
    if [ -n "$USB_DIAGNOSTICS" ] && [ -d "$APP_DIR" ] && [ -r "$LOG" ]; then
        cp "$LOG" "$USB_DIAGNOSTICS" 2>/dev/null || log "WARNING: failed to copy diagnostics to $USB_DIAGNOSTICS"
        sync 2>/dev/null || true
    fi
}

find_framebuffer() {
    for fb in /dev/fb0 /dev/fb; do
        if [ -e "$fb" ] && [ -w "$fb" ]; then
            FRAMEBUFFER="$fb"
            return 0
        fi
    done
    return 1
}

write_screen() {
    if [ -n "$FRAMEBUFFER" ] && [ -r "$IMAGE" ]; then
        cat "$IMAGE" > "$FRAMEBUFFER"
        return $?
    fi
    return 1
}

initial_diagnostics() {
    : > "$LOG"
    section "ha-chumby finite boot overlay"
    log "startup diagnostics started"
    log "invoked as: $0"
    log "APP_DIR=$APP_DIR"
    log "USB_ROOT=$USB_ROOT"
    log "USB_DIAGNOSTICS=$USB_DIAGNOSTICS"
    log "ZURK_ORIGINAL=$ZURK_ORIGINAL"
    log "ZURK_STARTUP=$ZURK_STARTUP"
    log "SPLASH_SECONDS=$SPLASH_SECONDS"
    log "PATH=$PATH"

    section "system before original startup"
    run_cmd "date" date
    run_cmd "uname -a" uname -a
    run_cmd "cat /proc/cmdline" cat /proc/cmdline
    run_cmd "mount" mount
    run_cmd "df -h" df -h
    run_cmd "ps before original startup" ps
    run_shell "listening ports before original startup" 'if command -v netstat >/dev/null 2>&1; then netstat -ln; else echo "netstat not found"; fi'
    psp_diagnostics
}

psp_diagnostics() {
    section "psp configuration state"
    run_shell "psp mount state" 'mount | grep " /psp " || true; mount | grep "/mnt/usb" || true'
    run_shell "psp directory listings" 'for d in /psp /mnt/usb/psp; do if [ -e "$d" ]; then echo "### $d"; ls -la "$d"; else echo "$d missing"; fi; done'
    run_shell "psp key files" 'for f in firsttime ts_settings network_config network_config_bak network_config_off disable_intro volume mute dimlevel daymode_brightness nightmode_brightness hostname flashplayer.cfg; do for base in /psp /mnt/usb/psp; do p="$base/$f"; if [ -e "$p" ]; then echo "### $p"; ls -l "$p"; cat "$p"; echo ""; fi; done; done'
    run_shell "psp first-run status" 'if [ -r /psp/firsttime ]; then value=$(cat /psp/firsttime); echo "firsttime=$value"; case "$value" in 0) echo "configured-state marker detected" ;; 1) echo "first-run marker detected" ;; *) echo "unknown firsttime value" ;; esac; else echo "/psp/firsttime missing"; fi; if [ -r /psp/ts_settings ]; then echo "touchscreen calibration file present"; else echo "touchscreen calibration file missing"; fi; if [ -r /psp/network_config ]; then echo "network configuration file present"; else echo "network configuration file missing"; fi'
}

radio_diagnostics() {
    section "radio preset diagnostics"
    run_shell "radio candidate files" 'for p in /mnt/usb/lighty/cgi-bin/chumote/control.cgi /mnt/usb/lighty/cgi-bin/chumote/control.cgi.zurk-original /mnt/usb/lighty/cgi-bin/chumote/streams /mnt/usb/lighty/cgi-bin/custom/multistreams.sh /mnt/usb/lighty/cgi-bin/custom/somafm.sh /psp/url_streams /mnt/usb/psp/url_streams /psp/fmradiostation /mnt/usb/psp/fmradiostation; do if [ -e "$p" ]; then echo "PASS $p"; ls -l "$p"; else echo "MISS $p"; fi; done'
    run_shell "radio preset matches" 'for p in /mnt/usb/lighty/cgi-bin/chumote/control.cgi /mnt/usb/lighty/cgi-bin/chumote/control.cgi.zurk-original /mnt/usb/lighty/cgi-bin/chumote/streams /mnt/usb/lighty/cgi-bin/custom/multistreams.sh /mnt/usb/lighty/cgi-bin/custom/somafm.sh /psp/url_streams /mnt/usb/psp/url_streams; do if [ -r "$p" ]; then echo "### $p"; grep -n -iE "radio1|radio2|radio3|playnow|btplay|66\.162\.107\.142|cpr1_lo|omropfryslan|stream|preset|station" "$p" || true; fi; done'
    run_shell "radio1 resolved url evidence" 'p=/mnt/usb/lighty/cgi-bin/chumote/control.cgi; if [ -r "$p" ]; then if grep -q "d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3" "$p"; then echo "radio1 configured URL: https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3"; elif grep -q "66.162.107.142/cpr1_lo" "$p"; then echo "radio1 configured URL: http://66.162.107.142/cpr1_lo"; else echo "radio1 configured URL not found by known patterns"; fi; else echo "$p missing or unreadable"; fi'
}

flashlite_audio_diagnostics() {
    section "flashlite audio pipeline diagnostics"
    run_shell "flashlite audio files" 'for p in /mnt/usb/psp/url_streams /mnt/usb/psp/url_streams.sprint13-original /mnt/usb/lighty/cgi-bin/randomshuffler.sh /mnt/usb/lighty/cgi-bin/player.sh /mnt/usb/lighty/cgi-bin/save_streams.sh /mnt/usb/lighty/html/chum.js /mnt/usb/lighty/lighttpd.conf /mnt/usb/controlpanel.swf /mnt/usb/lighty/html/falconwing-ihr_player.swf /mnt/usb/lighty/html/falconwing-pandora_player-2.15.swf; do if [ -e "$p" ]; then echo "PASS $p"; ls -l "$p"; else echo "MISS $p"; fi; done'
    run_shell "flashlite audio config contents" 'for p in /mnt/usb/psp/url_streams /mnt/usb/psp/url_streams.sprint13-original /mnt/usb/lighty/cgi-bin/randomshuffler.sh /mnt/usb/lighty/cgi-bin/player.sh /mnt/usb/lighty/cgi-bin/save_streams.sh; do if [ -r "$p" ]; then echo "### $p"; cat "$p"; echo ""; fi; done'
    run_shell "music redirect and cgi mapping" 'p=/mnt/usb/lighty/lighttpd.conf; if [ -r "$p" ]; then grep -n -iE "music\.m3u|randomshuffler|cgi.assign|alias.url|url.redirect" "$p" || true; else echo "$p missing"; fi'
    run_shell "usb music inventory" 'if [ -d /mnt/usb/music ]; then find /mnt/usb/music -maxdepth 1 -type f | sort; else echo "/mnt/usb/music missing"; fi'
}
show_splash() {
    section "ha-chumby splash"
    if [ ! -r "$IMAGE" ]; then
        log "ERROR: boot screen image not readable"
    else
        log "boot screen image found"
    fi

    if find_framebuffer; then
        log "using framebuffer $FRAMEBUFFER"
    else
        log "ERROR: no writable framebuffer found"
    fi

    if write_screen; then
        log "initial boot screen written"
    else
        log "ERROR: initial boot screen write failed"
    fi

    log "sleeping $SPLASH_SECONDS seconds before hand-off"
    copy_diagnostics_to_usb
    sleep "$SPLASH_SECONDS"
}

restore_zurk_runtime() {
    section "restore zurk startup"

    if [ -r "$ZURK_ORIGINAL" ]; then
        log "executing original Zurk startup: $ZURK_ORIGINAL"
        sh "$ZURK_ORIGINAL" >> "$LOG" 2>&1
        status=$?
        log "original Zurk startup exit code: $status"
        copy_diagnostics_to_usb
        return $status
    fi

    log "original Zurk startup not found at $ZURK_ORIGINAL"
    if [ -r "$ZURK_STARTUP" ]; then
        log "executing Zurk web-service startup fallback: $ZURK_STARTUP"
        sh "$ZURK_STARTUP" >> "$LOG" 2>&1
        status=$?
        log "Zurk web-service startup fallback exit code: $status"
        copy_diagnostics_to_usb
        return $status
    fi

    log "WARNING: no Zurk startup script found; returning to original boot anyway"
    copy_diagnostics_to_usb
    return 1
}

final_diagnostics() {
    section "handoff diagnostics"
    run_cmd "ps before hand-off exit" ps
    run_shell "listening ports before hand-off exit" 'if command -v netstat >/dev/null 2>&1; then netstat -ln; else echo "netstat not found"; fi'
    run_shell "http ui process snapshot" 'ps | grep -i "http"; ps | grep -i "lighty"; ps | grep -i "lighttpd"; ps | grep -i "chumby"; ps | grep -i "flash"; ps | grep -i "control"'
    run_shell "framebuffer process clues" 'for p in /proc/[0-9]*; do pid=${p#/proc/}; if [ -d "$p/fd" ]; then ls -l "$p/fd" 2>/dev/null | grep "/dev/fb" >/dev/null 2>&1 && echo "pid $pid has framebuffer fd"; fi; done'
    run_shell "runtime file checks" 'for p in /mnt/usb/lighty/cgi-bin /mnt/usb/lighty/cgi-bin/chumote/event.cgi /mnt/usb/lighty/cgi-bin/speak.pl /mnt/usb/lighty/lighttpd.conf /usr/chumby/scripts/fb_cgi.sh; do if [ -e "$p" ]; then echo "PASS $p"; ls -ld "$p"; else echo "FAIL $p missing"; fi; done'
    radio_diagnostics
    flashlite_audio_diagnostics
}

initial_diagnostics
show_splash
restore_zurk_runtime
final_diagnostics

log "exiting HA-Chumby overlay so original Chumby startup can continue"
copy_diagnostics_to_usb
exit 0
