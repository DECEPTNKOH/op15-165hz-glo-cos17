#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/module.log"

while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 5

settings put secure choice_mode_rate 165
settings put global app_extreme_high_refresh_switch 1
settings put system peak_refresh_rate 165.0

echo "[OP15-165Hz] $(date '+%H:%M:%S') Applied settings in service.sh" >> "$LOG"
