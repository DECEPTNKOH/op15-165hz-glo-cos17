#!/system/bin/sh
(
  while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
  done
  sleep 3
  settings put secure choice_mode_rate 120
  settings put global app_extreme_high_refresh_switch 0
  settings put system peak_refresh_rate 120.0
) &
