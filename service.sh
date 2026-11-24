#!/system/bin/sh
MODDIR=${0%/*}
# shellcheck source=common.sh
. "$MODDIR/common.sh"

clamp_120() {
  _int="${1%%.*}"
  if [ "$_int" -gt 120 ] 2>/dev/null; then
    echo "$2"
  else
    echo "$1"
  fi
}

normalize_orig() {
  _val="$1"
  _def="$2"
  if [ -z "$_val" ] || [ "$_val" = "null" ]; then
    echo "__UNSET__"
  elif is_valid_num "$_val"; then
    clamp_120 "$_val" "$_def"
  else
    echo "$_def"
  fi
}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 5

mkdir -p "$STATE_DIR"

# Если сработала защита от bootloop, не сбрасываем счётчик и не трогаем настройки
if [ -f "$BOOT_COUNT_FILE" ]; then
  _bc=$(tr -d '\r\n' < "$BOOT_COUNT_FILE" 2>/dev/null)
  if [ "${_bc:-0}" -ge 2 ] 2>/dev/null; then
    log "WARN: Bootloop protection active (boot_count=$_bc), skipping settings apply"
    exit 0
  fi
  rm -f "$BOOT_COUNT_FILE"
fi

# Фолбэк-бэкап (на случай установки из recovery или апгрейда с v1.5.0)
if [ ! -f "$BACKUP" ]; then
  ORIG_CHOICE=$(settings get secure choice_mode_rate 2>/dev/null | tr -d '\r')
  ORIG_EXTREME=$(settings get global app_extreme_high_refresh_switch 2>/dev/null | tr -d '\r')
  ORIG_PEAK=$(settings get system peak_refresh_rate 2>/dev/null | tr -d '\r')

  ORIG_CHOICE=$(normalize_orig "$ORIG_CHOICE" "120")
  if [ -z "$ORIG_EXTREME" ] || [ "$ORIG_EXTREME" = "null" ]; then
    ORIG_EXTREME="__UNSET__"
  elif ! is_valid_num "$ORIG_EXTREME" || [ "$ORIG_EXTREME" = "1" ]; then
    ORIG_EXTREME="0"
  fi
  ORIG_PEAK=$(normalize_orig "$ORIG_PEAK" "120.0")

  {
    echo "ORIG_CHOICE=$ORIG_CHOICE"
    echo "ORIG_EXTREME=$ORIG_EXTREME"
    echo "ORIG_PEAK=$ORIG_PEAK"
  } > "$BACKUP"
  chmod 0600 "$BACKUP"
  log "Saved fallback original settings to $BACKUP"
fi

LAST_APPLIED=""
[ -f "$APPLIED_FILE" ] && LAST_APPLIED=$(tr -d '\r' < "$APPLIED_FILE" 2>/dev/null)

if [ "$LAST_APPLIED" != "${VERSION:-unknown}" ]; then
  TRIES=0
  until apply_165_flags; do
    TRIES=$((TRIES + 1))
    if [ "$TRIES" -ge 5 ]; then
      log "ERROR: Failed to apply/verify 165Hz settings after $TRIES attempts"
      exit 1
    fi
    sleep 3
  done
  echo "${VERSION:-unknown}" > "$APPLIED_FILE"
  log "Applied and verified 165Hz settings in service.sh (${VERSION:-unknown})"
else
  log "Settings already applied for ${VERSION:-unknown}, skipping override"
fi
