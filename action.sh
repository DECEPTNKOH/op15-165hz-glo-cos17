#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/module.log"
STATE_DIR="/data/adb/op15_165hz_glo"
VERSION=$(grep '^version=' "$MODDIR/module.prop" 2>/dev/null | cut -d'=' -f2 | tr -d '\r')

echo "- Применение системных флагов 165 Гц..."
settings put secure choice_mode_rate 165
settings put global app_extreme_high_refresh_switch 1
settings put system peak_refresh_rate 165.0

mkdir -p "$STATE_DIR"
echo "${VERSION:-unknown}" > "$STATE_DIR/applied_version"
echo "[OP15-165Hz] $(date '+%H:%M:%S') Reapplied 165Hz settings via action.sh" >> "$LOG"
echo "- Готово: choice_mode_rate=165, app_extreme_high_refresh_switch=1, peak_refresh_rate=165.0"
