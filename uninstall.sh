#!/system/bin/sh
MODDIR=${0%/*}
ORIG_CHOICE="120"
ORIG_EXTREME="0"
ORIG_PEAK="120.0"

# Читаем бэкап до ухода в фон, пока каталог модуля не удалён
[ -f "$MODDIR/orig_settings.env" ] && . "$MODDIR/orig_settings.env"

(
  while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
  done
  sleep 3
  settings put secure choice_mode_rate "$ORIG_CHOICE"
  settings put global app_extreme_high_refresh_switch "$ORIG_EXTREME"
  settings put system peak_refresh_rate "$ORIG_PEAK"
) &
