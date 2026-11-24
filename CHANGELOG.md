# Changelog

## v1.5.2
- В `customize.sh` добавлены проверка устройства (`CPH2747` / `OP611FL1`) и проверка поддержки 165 Гц (`extremeHighEnable` + `rateId="7"`) в XML с возможностью обхода через `FORCE_INSTALL=1`.
- В `post-fs-data.sh` вставка `<extremeHighRate>` переведена на переносимый `awk`; усилена валидация структуры XML (корневые теги и отсутствие дублей `defaultMaxRate`).
- Хранилище состояния (`orig_settings.env` и `applied_version`) вынесено в `/data/adb/op15_165hz_glo/`, чтобы бэкап переживал обновления модуля; чтение настроек защищено от `null` и не использует `source`.
- `service.sh` сделан идемпотентным: системные флаги 165 Гц применяются один раз при установке/обновлении и не перебивают ручной выбор пользователя после перезагрузок.
- В CI (`release.yml`) добавлены линтинг `shellcheck` и публикация контрольной суммы `.sha256` для релизного архива.

## v1.5.1
- Устранён риск дублирования `defaultMaxRate` и вставки тегов в комментарии XML в `post-fs-data.sh`.
- Добавлена валидация результата патча перед `mount --bind` и проверка кода возврата `mount`.
- Версия в `customize.sh` и `post-fs-data.sh` читается динамически из `module.prop`; параметры патча вынесены в переменные.
- При установке из recovery (`BOOTMODE != true`) отсутствие `/my_product` выводит предупреждение вместо `abort`.
- `service.sh` сохраняет исходные настройки пользователя (`orig_settings.env`), а `uninstall.sh` восстанавливает их.
- Улучшен CI (`release.yml`): проверка совпадения тега с `module.prop`, публикация релиза до обновления `update.json`, вырезка заметок только текущей версии.

## v1.5.0
- Динамический патч `/my_product/etc/refresh_rate_config.xml` и `/my_product/etc/sys_dynamic_frame_config.xml` через `mount --bind` в `post-fs-data.sh`.
- Подняты `defaultRateId="7-1-2-7"`, `defaultMaxRate="165"`, `maxrefreshsettings="7"`, отключён 120 Гц `enableAppSwitchBoost`.
- Добавлены `com.android.launcher` и `com.android.systemui` в `<extremeHighRate>`.
- Добавлен `service.sh` для применения `choice_mode_rate=165`, `app_extreme_high_refresh_switch=1`, `peak_refresh_rate=165.0`.
- Добавлены `customize.sh`, `uninstall.sh` и поддержка обновлений через `update.json`.
