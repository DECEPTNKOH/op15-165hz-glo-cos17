# Changelog

## v1.5.3
- Исправлена генерация `update.json` в CI (переведена на `python3` с JSON-валидацией вместо `printf`).
- Добавлен `action.sh` для повторного применения флагов 165 Гц по кнопке в KernelSU / Magisk / APatch без перезагрузки.
- В `service.sh` добавлена защита от сохранения значений >120 Гц как исходных при обновлении с v1.5.0; ужесточена проверка чисел `is_valid_num`.
- В `post-fs-data.sh` усилена валидация `<config>` (`maxrefreshsettings`, `enableAppSwitchBoost`, `disableViewOverrideDefault`), добавлена ротация лога (`module.log.old`) и переносимый синтаксис `awk` (`[ \t]`).
- В `customize.sh` добавлена строгая проверка модели `CPH2747` / `OP611FL1` с возможностью обхода через `/data/local/tmp/force_op15_165hz` или `FORCE_INSTALL=1`.
- Добавлена лицензия MIT (`LICENSE`) и актуализирована `docs/ARCHITECTURE.md`.

## v1.5.2
- В `customize.sh` добавлены проверка устройства (`CPH2747` / `OP611FL1`) и проверка поддержки 165 Гц (`extremeHighEnable` + `rateId="7"`) в XML.
- В `post-fs-data.sh` вставка `<extremeHighRate>` переведена на `awk`; усилена валидация корневых тегов XML и отсутствия дублей `defaultMaxRate`.
- Хранилище состояния вынесено в `/data/adb/op15_165hz_glo/`; `service.sh` сделан идемпотентным по версии.
- В CI добавлены `shellcheck` и контрольная сумма `.sha256`.

## v1.5.1
- Устранён риск дублирования `defaultMaxRate`, добавлена валидация патча перед `mount --bind` и бэкап настроек пользователя.

## v1.5.0
- Первый релиз динамического патча `refresh_rate_config.xml` и `sys_dynamic_frame_config.xml` для OnePlus 15 GLO (ColorOS 17).
