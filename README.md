# OnePlus 15 GLO 165Hz Unlock (ColorOS 17)

Root-модуль (KernelSU / Magisk / APatch) для динамической разблокировки **165 Гц** во всех приложениях и системных анимациях на **OnePlus 15 (GLO, ColorOS 17)**.

- **Автор:** DECEPTNKOH
- **Проверено на:** OnePlus 15 GLO (`CPH2747` / `OP611FL1`), ColorOS 17 (Android 17, `refresh_rate_config` v20260922), KernelSU Next
- **Совместимость с root:** KernelSU / KernelSU Next, Magisk, APatch (автообновление через `update.json` и кнопка `action.sh`)

> **Внимание:** модуль изменяет системные профили дисплея через обратимый `mount --bind` (со встроенной защитой от bootloop после 2 неудачных загрузок). Работа на 165 Гц может незначительно влиять на автономность и нагрев.

## Установка
1. Скачайте актуальный ZIP (и `.sha256` для проверки) из раздела [**Releases**](https://github.com/DECEPTNKOH/op15-165hz-glo-cos17/releases).
2. Прошейте архив в **KernelSU / Magisk / APatch** и перезагрузите смартфон.
3. В настройках экрана выберите режим **Высокая** или **Автовыбор**. Если после смены режима частота снизилась, нажмите кнопку действия (**Action / Выполнить**) на карточке модуля в менеджере.
4. Для принудительной установки на совместимое устройство с другим кодом модели предварительно создайте файл `/data/local/tmp/force_op15_165hz` (или передайте `FORCE_INSTALL=1` в CLI).

## Проверка работы и восстановление
- **Лог модуля:** `su -c "cat /data/adb/modules/op15_165hz_glo/module.log"`
- **Статус конфига:** `su -c "dumpsys oplusscreenmode | grep -E 'Config\{|isExtremeHighSettingOn'"` (ожидается `mDefaultMaxRate=165.0` и `isExtremeHighSettingOn=true`).
- **Отключение без менеджера root:** создайте `touch /data/adb/modules/op15_165hz_glo/disable` (через ADB/recovery) или загрузитесь в Safe Mode (KernelSU / Magisk / APatch) и перезагрузите устройство.
- **Важно после отключения:** простое отключение модуля не запускает `uninstall.sh`, поэтому системные флаги `settings` остаются на 165. Для полного сброса выполните ручной откат:

      su -c "settings put secure choice_mode_rate 120; settings put global app_extreme_high_refresh_switch 0; settings put system peak_refresh_rate 120.0; rm -rf /data/adb/op15_165hz_glo"

## Известные ограничения
- **Камера:** видоискатель остаётся в 60 Гц (ограничение HAL/приложения; запись видео 120 FPS работает штатно).
- **Рабочий стол → «Недавние»:** 1–2 сек 120 Гц из-за `PRIORITY_LAUNCHER_REQUEST` в `OplusLauncher.apk` (из приложений держится 165 Гц).
- **Игры:** Game Space может отдельно ограничивать FPS.

## Документация
Принцип работы, таблица `rateId`, поведение LTPO (33–165 Гц) и известные ограничения описаны в [**docs/ARCHITECTURE.md**](docs/ARCHITECTURE.md).
