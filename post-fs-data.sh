#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/module.log"
PATCH_DIR="$MODDIR/patched"
VERSION=$(grep '^version=' "$MODDIR/module.prop" 2>/dev/null | cut -d'=' -f2 | tr -d '\r')

# Конфигурация патча
TARGET_RATE_ID="7-1-2-7"
TARGET_MAX_RATE="165"
TARGET_MAX_SETTINGS="7"
EXTREME_RATE_ID="7"

log() {
  echo "[OP15-165Hz] $(date '+%H:%M:%S') $1" >> "$LOG"
}

bind_file() {
  SRC="$1"
  DST="$2"
  if [ -s "$DST" ]; then
    chmod 0644 "$DST"
    chown 0:0 "$DST"
    SECTX=$(ls -Z "$SRC" 2>/dev/null | awk '{print $1}')
    case "$SECTX" in
      u:object_r:*) ;;
      *) SECTX="u:object_r:system_file:s0" ;;
    esac
    chcon "$SECTX" "$DST"
    if mount --bind "$DST" "$SRC"; then
      log "Mounted $SRC (SELinux: $SECTX)"
    else
      log "ERROR: mount --bind failed for $SRC"
    fi
  else
    log "ERROR: Empty patched file for $SRC, skipped"
  fi
}

rm -f "$LOG"
mkdir -p "$PATCH_DIR"
log "Start post-fs-data ${VERSION:-unknown}"

# 1. Патч refresh_rate_config.xml
SRC_RR="/my_product/etc/refresh_rate_config.xml"
DST_RR="$PATCH_DIR/refresh_rate_config.xml"
if [ -f "$SRC_RR" ]; then
  cp -f "$SRC_RR" "$DST_RR"

  sed -i \
    -e "/^[[:space:]]*<config / s/defaultRateId=\"[0-9]-[0-9]-[0-9]-[0-9]\"/defaultRateId=\"$TARGET_RATE_ID\"/" \
    -e "/^[[:space:]]*<config / s/enableAppSwitchBoost=\"true\"/enableAppSwitchBoost=\"false\"/" \
    -e "/^[[:space:]]*<config / s/maxrefreshsettings=\"[0-9]\"/maxrefreshsettings=\"$TARGET_MAX_SETTINGS\"/" \
    -e "/^[[:space:]]*<config / s/disableViewOverrideDefault=\"false\"/disableViewOverrideDefault=\"true\"/" \
    -e "/[Cc]amera/! s/rateId=\"[0-9]-[0-9]-[0-9]-[0-9]\"/rateId=\"$TARGET_RATE_ID\"/g" \
    "$DST_RR"

  # Безопасная установка defaultMaxRate без дублирования атрибута
  if grep -q 'defaultMaxRate=' "$DST_RR"; then
    sed -i -e "/^[[:space:]]*<config / s/defaultMaxRate=\"[^\"]*\"/defaultMaxRate=\"$TARGET_MAX_RATE\"/" "$DST_RR"
  else
    sed -i -e "/^[[:space:]]*<config / s/<config /<config defaultMaxRate=\"$TARGET_MAX_RATE\" /" "$DST_RR"
  fi

  # Добавляем launcher и systemui в extremeHighRate только если их ещё нет
  if ! grep -q 'extremeHighRate.*com\.android\.launcher' "$DST_RR"; then
    sed -i -e "0,/^[[:space:]]*<config / s|<config |<extremeHighRate package=\"com.android.launcher\" rateId=\"$EXTREME_RATE_ID\" /> <config |" "$DST_RR"
  fi
  if ! grep -q 'extremeHighRate.*com\.android\.systemui' "$DST_RR"; then
    sed -i -e "0,/^[[:space:]]*<config / s|<config |<extremeHighRate package=\"com.android.systemui\" rateId=\"$EXTREME_RATE_ID\" /> <config |" "$DST_RR"
  fi

  # Валидация результата патча
  if grep -q "defaultRateId=\"$TARGET_RATE_ID\"" "$DST_RR" && grep -q "defaultMaxRate=\"$TARGET_MAX_RATE\"" "$DST_RR"; then
    bind_file "$SRC_RR" "$DST_RR"
  else
    log "ERROR: Validation failed for $SRC_RR (format changed after OTA?), mount skipped"
  fi
else
  log "ERROR: $SRC_RR not found"
fi

# 2. Патч sys_dynamic_frame_config.xml
SRC_DF="/my_product/etc/sys_dynamic_frame_config.xml"
DST_DF="$PATCH_DIR/sys_dynamic_frame_config.xml"
if [ -f "$SRC_DF" ]; then
  cp -f "$SRC_DF" "$DST_DF"
  sed -i -e "s/targetFramerate=\"120\"/targetFramerate=\"$TARGET_MAX_RATE\"/g" "$DST_DF"

  if grep -q "targetFramerate=\"$TARGET_MAX_RATE\"" "$DST_DF"; then
    bind_file "$SRC_DF" "$DST_DF"
  else
    log "ERROR: Validation failed for $SRC_DF, mount skipped"
  fi
else
  log "ERROR: $SRC_DF not found"
fi
