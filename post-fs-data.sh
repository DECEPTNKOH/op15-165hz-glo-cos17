#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/module.log"
PATCH_DIR="$MODDIR/patched"

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
    mount --bind "$DST" "$SRC"
    log "Mounted $SRC (SELinux: $SECTX)"
  else
    log "ERROR: Empty patched file for $SRC, skipped"
  fi
}

rm -f "$LOG"
mkdir -p "$PATCH_DIR"
log "Start post-fs-data v1.5"

# 1. Патч refresh_rate_config.xml
SRC_RR="/my_product/etc/refresh_rate_config.xml"
DST_RR="$PATCH_DIR/refresh_rate_config.xml"
if [ -f "$SRC_RR" ]; then
  cp -f "$SRC_RR" "$DST_RR"
  sed -i \
    -e '/<config / s/defaultRateId="[0-9]-[0-9]-[0-9]-[0-9]"/defaultRateId="7-1-2-7"/g' \
    -e '/<config / s/enableAppSwitchBoost="true"/enableAppSwitchBoost="false"/g' \
    -e '/<config / s/maxrefreshsettings="[0-9]"/maxrefreshsettings="7"/g' \
    -e '/<config / s/disableViewOverrideDefault="false"/disableViewOverrideDefault="true"/g' \
    -e '/[Cc]amera/! s/rateId="[0-9]-[0-9]-[0-9]-[0-9]"/rateId="7-1-2-7"/g' \
    -e 's|<config |<extremeHighRate package="com.android.launcher" rateId="7" /> <extremeHighRate package="com.android.systemui" rateId="7" /> <config defaultMaxRate="165" |' \
    "$DST_RR"
  bind_file "$SRC_RR" "$DST_RR"
else
  log "ERROR: $SRC_RR not found"
fi

# 2. Патч sys_dynamic_frame_config.xml
SRC_DF="/my_product/etc/sys_dynamic_frame_config.xml"
DST_DF="$PATCH_DIR/sys_dynamic_frame_config.xml"
if [ -f "$SRC_DF" ]; then
  cp -f "$SRC_DF" "$DST_DF"
  sed -i \
    -e 's/targetFramerate="120"/targetFramerate="165"/g' \
    "$DST_DF"
  bind_file "$SRC_DF" "$DST_DF"
else
  log "ERROR: $SRC_DF not found"
fi
