#!/system/bin/sh
STATE_DIR="/data/adb/op15_165hz_glo"
BACKUP="$STATE_DIR/orig_settings.env"

is_valid_num() {
  echo "$1" | grep -Eq '^[0-9]+(\.[0-9]+)?$'
}

read_backup() {
  _key="$1"
  _def="$2"
  _val=""
  if [ -f "$BACKUP" ]; then
    _val=$(grep "^${_key}=" "$BACKUP" 2>/dev/null | head -n 1 | cut -d'=' -f2 | tr -d '\r')
  fi
  if is_valid_num "$_val"; then
    echo "$_val"
  else
    echo "$_def"
  fi
}

ORIG_CHOICE=$(read_backup "ORIG_CHOICE" "120")
ORIG_EXTREME=$(read_backup "ORIG_EXTREME" "0")
ORIG_PEAK=$(read_backup "ORIG_PEAK" "120.0")

(
  while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
  done
  sleep 3
  settings put secure choice_mode_rate "$ORIG_CHOICE"
  settings put global app_extreme_high_refresh_switch "$ORIG_EXTREME"
  settings put system peak_refresh_rate "$ORIG_PEAK"
  rm -rf "$STATE_DIR"
) &
