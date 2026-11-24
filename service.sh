#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/module.log"
BACKUP="$MODDIR/orig_settings.env"

while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 5

# Сохраняем исходные настройки один раз для чистого отката в uninstall.sh
if [ ! -f "$BACKUP" ]; then
  ORIG_CHOICE=$(settings get secure choice_mode_rate 2>/dev/null)
  ORIG_EXTREME=$(settings get global app_extreme_high_refresh_switch 2>/dev/null)
  ORIG_PEAK=$(settings get system peak_refresh_rate 2>/dev/null)
  {
    echo "ORIG_CHOICE=${ORIG_CHOICE:-120}"
    echo "ORIG_EXTREME=${ORIG_EXTREME:-0}"
    echo "ORIG_PEAK=${ORIG_PEAK:-120.0}"
  } > "$BACKUP"
fi

settings put secure choice_mode_rate 165
settings put global app_extreme_high_refresh_switch 1
settings put system peak_refresh_rate 165.0

echo "[OP15-165Hz] $(date '+%H:%M:%S') Applied settings in service.sh" >> "$LOG"
