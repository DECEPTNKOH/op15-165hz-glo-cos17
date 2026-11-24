# Changelog

## v1.5.0
- Динамический патч `/my_product/etc/refresh_rate_config.xml` и `/my_product/etc/sys_dynamic_frame_config.xml` через `mount --bind` в `post-fs-data.sh`.
- Подняты `defaultRateId="7-1-2-7"`, `defaultMaxRate="165"`, `maxrefreshsettings="7"`, отключён 120 Гц `enableAppSwitchBoost`.
- Добавлены `com.android.launcher` и `com.android.systemui` в `<extremeHighRate>`.
- Добавлен `service.sh` для применения `choice_mode_rate=165`, `app_extreme_high_refresh_switch=1`, `peak_refresh_rate=165.0`.
- Добавлены `customize.sh`, `uninstall.sh` и поддержка обновлений через `update.json` (KernelSU / Magisk / APatch).
