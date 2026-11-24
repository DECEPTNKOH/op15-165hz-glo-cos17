#!/system/bin/sh
MODDIR=${0%/*}
# shellcheck source=common.sh
. "$MODDIR/common.sh"

echo "=== OP15 165Hz Status (${VERSION:-unknown}) ==="

if [ -f "$BOOT_COUNT_FILE" ]; then
  _bc=$(tr -d '\r\n' < "$BOOT_COUNT_FILE" 2>/dev/null)
  if [ "${_bc:-0}" -ge 2 ] 2>/dev/null; then
    echo "! Активна защита от bootloop (boot_count=$_bc)."
    echo "! Удалите $BOOT_COUNT_FILE вручную только если уверены в совместимости."
  fi
fi

MOUNT_OK=1
if is_mounted "$SRC_RR" && is_mounted "$SRC_DF"; then
  echo "- XML bind-mounts: OK"
else
  echo "! Внимание: XML-патчи НЕ смонтированы (проверьте $LOG)"
  MOUNT_OK=0
fi

echo "- Применение и проверка системных флагов 165 Гц..."
if apply_165_flags; then
  mkdir -p "$STATE_DIR"
  echo "${VERSION:-unknown}" > "$APPLIED_FILE"
  log "Reapplied and verified 165Hz settings via action.sh (mount_ok=$MOUNT_OK)"
  echo "- Флаги подтверждены: 165 / 1 / 165.0"
else
  log "ERROR: Failed to apply/verify 165Hz settings via action.sh"
  echo "! Ошибка: не удалось подтвердить запись системных флагов"
  exit 1
fi

STATUS=$(dumpsys oplusscreenmode 2>/dev/null | grep -E 'mDefaultMaxRate=|isExtremeHighSettingOn=' | head -n 2)
if [ -n "$STATUS" ]; then
  echo "- oplusscreenmode:"
  echo "$STATUS"
fi
