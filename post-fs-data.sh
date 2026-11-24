#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/module.log"
PATCH_DIR="$MODDIR/patched"
VERSION=$(grep '^version=' "$MODDIR/module.prop" 2>/dev/null | cut -d'=' -f2 | tr -d '\r')

TARGET_RATE_ID="7-1-2-7"
TARGET_MAX_RATE="165"
TARGET_MAX_SETTINGS="7"
EXTREME_RATE_ID="7"

log() {
  echo "[OP15-165Hz] $(date '+%H:%M:%S') $1" >> "$LOG"
}

prepare_metadata() {
  _src="$1"
  _dst="$2"
  chmod 0644 "$_dst"
  chown 0:0 "$_dst"
  # shellcheck disable=SC2012
  _sectx=$(ls -Z "$_src" 2>/dev/null | awk '{print $1}')
  case "$_sectx" in
    u:object_r:*) ;;
    *) _sectx="u:object_r:system_file:s0" ;;
  esac
  if ! chcon "$_sectx" "$_dst" 2>/dev/null; then
    log "WARN: chcon failed for $_dst (target context: $_sectx)"
  fi
}

bind_and_verify() {
  _src="$1"
  _dst="$2"
  if mount --bind "$_dst" "$_src" && grep -q " $_src " /proc/mounts; then
    log "Mounted and verified $_src"
    return 0
  else
    log "ERROR: mount --bind verification failed for $_src"
    return 1
  fi
}

insert_extreme_pkg() {
  _file="$1"
  _pkg="$2"
  if ! grep -q "extremeHighRate.*package=\"${_pkg}\"" "$_file"; then
    awk -v pkg="$_pkg" -v rid="$EXTREME_RATE_ID" '
      !done && /^[ \t]*<config / {
        print "  <extremeHighRate package=\"" pkg "\" rateId=\"" rid "\" />"
        done=1
      }
      { print }
    ' "$_file" > "${_file}.tmp" && mv -f "${_file}.tmp" "$_file"
  fi
}

[ -f "$LOG" ] && mv -f "$LOG" "${LOG}.old"
mkdir -p "$PATCH_DIR"
log "Start post-fs-data ${VERSION:-unknown}"

SRC_RR="/my_product/etc/refresh_rate_config.xml"
DST_RR="$PATCH_DIR/refresh_rate_config.xml"
SRC_DF="/my_product/etc/sys_dynamic_frame_config.xml"
DST_DF="$PATCH_DIR/sys_dynamic_frame_config.xml"

RR_READY=0
DF_READY=0

if [ -f "$SRC_RR" ]; then
  if ! grep -q '<refresh_rate_config' "$SRC_RR" || ! grep -q '^[[:space:]]*<config ' "$SRC_RR"; then
    log "ERROR: Unexpected XML structure in $SRC_RR"
  else
    cp -f "$SRC_RR" "$DST_RR"
    sed -i \
      -e "/^[[:space:]]*<config / s/defaultRateId=\"[0-9]-[0-9]-[0-9]-[0-9]\"/defaultRateId=\"$TARGET_RATE_ID\"/" \
      -e "/^[[:space:]]*<config / s/enableAppSwitchBoost=\"true\"/enableAppSwitchBoost=\"false\"/" \
      -e "/^[[:space:]]*<config / s/maxrefreshsettings=\"[0-9]\"/maxrefreshsettings=\"$TARGET_MAX_SETTINGS\"/" \
      -e "/^[[:space:]]*<config / s/disableViewOverrideDefault=\"false\"/disableViewOverrideDefault=\"true\"/" \
      -e "/[Cc]amera/! s/rateId=\"[0-9]-[0-9]-[0-9]-[0-9]\"/rateId=\"$TARGET_RATE_ID\"/g" \
      "$DST_RR"

    if grep -q '^[[:space:]]*<config .*defaultMaxRate=' "$DST_RR"; then
      sed -i -e "/^[[:space:]]*<config / s/defaultMaxRate=\"[^\"]*\"/defaultMaxRate=\"$TARGET_MAX_RATE\"/" "$DST_RR"
    else
      sed -i -e "/^[[:space:]]*<config / s/<config /<config defaultMaxRate=\"$TARGET_MAX_RATE\" /" "$DST_RR"
    fi

    insert_extreme_pkg "$DST_RR" "com.android.launcher"
    insert_extreme_pkg "$DST_RR" "com.android.systemui"

    DUP_MAX=$(awk '/^[ \t]*<config / { c += gsub(/defaultMaxRate=/, "&") } END { print c + 0 }' "$DST_RR")
    if [ -s "$DST_RR" ] \
      && grep -q '<refresh_rate_config' "$DST_RR" \
      && grep -q '</refresh_rate_config>' "$DST_RR" \
      && grep -q "defaultRateId=\"$TARGET_RATE_ID\"" "$DST_RR" \
      && grep -q "defaultMaxRate=\"$TARGET_MAX_RATE\"" "$DST_RR" \
      && grep -q "maxrefreshsettings=\"$TARGET_MAX_SETTINGS\"" "$DST_RR" \
      && grep -q 'enableAppSwitchBoost="false"' "$DST_RR" \
      && grep -q 'disableViewOverrideDefault="true"' "$DST_RR" \
      && [ "$DUP_MAX" = "1" ]; then
      prepare_metadata "$SRC_RR" "$DST_RR"
      RR_READY=1
    else
      log "ERROR: Validation failed for $SRC_RR (dup_max=$DUP_MAX)"
    fi
  fi
else
  log "ERROR: $SRC_RR not found"
fi

if [ -f "$SRC_DF" ]; then
  cp -f "$SRC_DF" "$DST_DF"
  sed -i -e "s/targetFramerate=\"120\"/targetFramerate=\"$TARGET_MAX_RATE\"/g" "$DST_DF"

  if [ -s "$DST_DF" ] \
    && grep -q "targetFramerate=\"$TARGET_MAX_RATE\"" "$DST_DF" \
    && ! grep -q 'targetFramerate="120"' "$DST_DF"; then
    prepare_metadata "$SRC_DF" "$DST_DF"
    DF_READY=1
  else
    log "ERROR: Validation failed for $SRC_DF (unpatched 120Hz entries remain or empty)"
  fi
else
  log "ERROR: $SRC_DF not found"
fi

if [ "$RR_READY" = "1" ] && [ "$DF_READY" = "1" ]; then
  if bind_and_verify "$SRC_RR" "$DST_RR"; then
    if ! bind_and_verify "$SRC_DF" "$DST_DF"; then
      umount "$SRC_RR" 2>/dev/null
      log "ERROR: Atomic rollback executed for $SRC_RR"
    fi
  fi
else
  log "ERROR: Atomic mount aborted (RR_READY=$RR_READY, DF_READY=$DF_READY)"
fi
