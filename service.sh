#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/module.log"
STATE_DIR="/data/adb/op15_165hz_glo"
BACKUP="$STATE_DIR/orig_settings.env"
APPLIED_FILE="$STATE_DIR/applied_version"
VERSION=$(grep '^version=' "$MODDIR/module.prop" 2>/dev/null | cut -d'=' -f2 | tr -d '\r')

log() {
  echo "[OP15-165Hz] $(date '+%H:%M:%S') $1" >> "$LOG"
}

is_valid_num() {
  echo "$1" | grep -Eq '^[0-9]+(\.[0-9]+)?$'
}

clamp_120() {
  awk -v v="$1" -v def="$2" 'BEGIN { print (v + 0 > 120) ? def : v }'
}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 5

mkdir -p "$STATE_DIR"

# Сохраняем исходные настройки один раз (с защитой от значения >120 после v1.5.0)
if [ ! -f "$BACKUP" ]; then
  ORIG_CHOICE=$(settings get secure choice_mode_rate 2>/dev/null | tr -d '\r')
  ORIG_EXTREME=$(settings get global app_extreme_high_refresh_switch 2>/dev/null | tr -d '\r')
  ORIG_PEAK=$(settings get system peak_refresh_rate 2>/dev/null | tr -d '\r')

  is_valid_num "$ORIG_CHOICE" || ORIG_CHOICE="120"
  is_valid_num "$ORIG_EXTREME" || ORIG_EXTREME="0"
  is_valid_num "$ORIG_PEAK" || ORIG_PEAK="120.0"

  ORIG_CHOICE=$(clamp_120 "$ORIG_CHOICE" "120")
  [ "$ORIG_EXTREME" = "1" ] && ORIG_EXTREME="0"
  ORIG_PEAK=$(clamp_120 "$ORIG_PEAK" "120.0")

  {
    echo "ORIG_CHOICE=$ORIG_CHOICE"
    echo "ORIG_EXTREME=$ORIG_EXTREME"
    echo "ORIG_PEAK=$ORIG_PEAK"
  } > "$BACKUP"
  chmod 0600 "$BACKUP"
  log "Saved original settings to $BACKUP"
fi

LAST_APPLIED=""
[ -f "$APPLIED_FILE" ] && LAST_APPLIED=$(tr -d '\r' < "$APPLIED_FILE" 2>/dev/null)

if [ "$LAST_APPLIED" != "${VERSION:-unknown}" ]; then
  settings put secure choice_mode_rate 165
  settings put global app_extreme_high_refresh_switch 1
  settings put system peak_refresh_rate 165.0
  echo "${VERSION:-unknown}" > "$APPLIED_FILE"
  log "Applied 165Hz settings in service.sh (${VERSION:-unknown})"
else
  log "Settings already applied for ${VERSION:-unknown}, skipping override"
fi
