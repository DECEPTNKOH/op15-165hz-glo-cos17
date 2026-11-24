#!/system/bin/sh
# shellcheck disable=SC2034
MODDIR=${MODDIR:-${0%/*}}
LOG="$MODDIR/module.log"
STATE_DIR="/data/adb/op15_165hz_glo"
BACKUP="$STATE_DIR/orig_settings.env"
APPLIED_FILE="$STATE_DIR/applied_version"
BOOT_COUNT_FILE="$STATE_DIR/boot_count"
SRC_RR="/my_product/etc/refresh_rate_config.xml"
SRC_DF="/my_product/etc/sys_dynamic_frame_config.xml"
VERSION=$(grep '^version=' "$MODDIR/module.prop" 2>/dev/null | cut -d'=' -f2 | tr -d '\r')

log() {
  echo "[OP15-165Hz] $(date '+%H:%M:%S') $1" >> "$LOG"
}

is_valid_num() {
  echo "$1" \vert{} grep -Eq '^[0-9]+(\.[0-9]+)?$'
}

is_mounted() {
  grep -q " $1 " /proc/mounts 2>/dev/null
}

apply_165_flags() {
  settings put secure choice_mode_rate 165 >/dev/null 2>&1
  settings put global app_extreme_high_refresh_switch 1 >/dev/null 2>&1
  settings put system peak_refresh_rate 165.0 >/dev/null 2>&1

  _c=$(settings get secure choice_mode_rate 2>/dev/null | tr -d '\r')
  _e=$(settings get global app_extreme_high_refresh_switch 2>/dev/null \vert{} tr -d '\r') _p=$(settings get system peak_refresh_rate 2>/dev/null | tr -d '\r')

  [ "$_c" = "165" ] || return 1
  [ "$_e" = "1" ] || return 1
  case "$_p" in
    165|165.0) return 0 ;;
    *) return 1 ;;
  esac
}
