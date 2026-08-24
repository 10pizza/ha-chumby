#!/bin/sh
# Lightweight stock music player snapshot.
# Keep this small: the Chumby Classic is memory constrained while FlashLite runs.

LABEL="$1"
if [ -z "$LABEL" ]; then
    LABEL="snapshot"
fi

OUT="/mnt/usb/ha-chumby/music-player-${LABEL}.txt"
TMP_OUT="/tmp/ha-chumby-music-player-${LABEL}.txt"

write_line() {
    echo "$*" >> "$TMP_OUT"
}

section() {
    write_line ""
    write_line "--- $* ---"
}

copy_file_if_present() {
    path="$1"
    if [ -e "$path" ]; then
        section "$path"
        ls -l "$path" >> "$TMP_OUT" 2>&1
        if [ -f "$path" ]; then
            sed -n '1,80p' "$path" >> "$TMP_OUT" 2>&1
        fi
    fi
}

: > "$TMP_OUT"
write_line "# HA-Chumby stock music player lightweight snapshot"
write_line "label=$LABEL"
write_line "date=$(date '+%Y-%m-%d %H:%M:%S')"

section "uptime"
uptime >> "$TMP_OUT" 2>&1

section "memory"
free >> "$TMP_OUT" 2>&1

section "processes"
ps >> "$TMP_OUT" 2>&1

section "key state files"
copy_file_if_present /tmp/flashplayer.event
copy_file_if_present /tmp/musicsource
copy_file_if_present /psp/url_streams
copy_file_if_present /mnt/usb/psp/url_streams
copy_file_if_present /psp/volume
copy_file_if_present /psp/mute

section "tmp candidates"
for p in /tmp/*event* /tmp/*music* /tmp/*player* /tmp/*btplay*; do
    if [ -e "$p" ]; then
        ls -l "$p" >> "$TMP_OUT" 2>&1
    fi
done

section "recent access log music lines"
if [ -r /mnt/usb/tmp/access.log ]; then
    grep -iE 'music\.m3u|randomshuffler|UserPlayer|MusicPlayer|btplay|stream|radio' /mnt/usb/tmp/access.log | tail -40 >> "$TMP_OUT" 2>&1
else
    write_line "/mnt/usb/tmp/access.log not readable"
fi

section "recent error log"
if [ -r /mnt/usb/tmp/error.log ]; then
    tail -40 /mnt/usb/tmp/error.log >> "$TMP_OUT" 2>&1
else
    write_line "/mnt/usb/tmp/error.log not readable"
fi

cp "$TMP_OUT" "$OUT" 2>/dev/null || true
sync 2>/dev/null || true
write_line "snapshot copied to $OUT"
