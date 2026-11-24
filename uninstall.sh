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
  if [ "$_val" = "__UNSET__" ]; then
    echo "__UNSET__"
  elif is_valid_num "$_val"; then
    echo "$_val"
  else
    echo "$_def"
  fi
}

restore_setting() {
  _ns="$1"
  _key="$2"
  _val="$3"
  if [ "$_val" = "__UNSET__" ]; then
    settings delete "$_ns" "$_key" >/dev/null 2>&1
  else
    settings put "$_ns" "$_key" "$_val" >/dev/null 2>&1
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
  restore_setting secure choice_mode_rate "$ORIG_CHOICE"
  restore_setting global app_extreme_high_refresh_switch "$ORIG_EXTREME"
  restore_setting system peak_refresh_rate "$ORIG_PEAK"
  rm -rf "$STATE_DIR"
) &
