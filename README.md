# OnePlus 15 GLO 165Hz Unlock (ColorOS 17)

Root-модуль (KernelSU / Magisk / APatch) для динамической разблокировки **165 Гц** во всех приложениях и системных анимациях на **OnePlus 15 (GLO, ColorOS 17)**.

- **Автор:** DECEPTNKOH
- **Устройство:** OnePlus 15 GLO (`CPH2747` / `OP611FL1`), ColorOS 17 (Android 17)
- **Root:** KernelSU / Magisk / APatch (поддерживается автообновление через `update.json` и кнопка быстрого применения `action.sh`)

> **Внимание:** модуль изменяет системные профили дисплея через обратимый `mount --bind`. Работа на 165 Гц может незначительно влиять на автономность и нагрев в отдельных сценариях.

## Установка
1. Скачайте актуальный ZIP (и `.sha256` для проверки) из раздела [**Releases**](https://github.com/DECEPTNKOH/op15-165hz-glo-cos17/releases).
2. Прошейте архив в **KernelSU / Magisk / APatch** и перезагрузите смартфон.
3. В настройках экрана выберите режим **Высокая** или **Автовыбор**. Если после смены режима в настройках частота снизилась, нажмите кнопку действия (**Action / Выполнить**) на карточке модуля в менеджере.
4. Для принудительной установки на совместимое устройство с другим кодом модели предварительно создайте файл `/data/local/tmp/force_op15_165hz` (или передайте `FORCE_INSTALL=1` в CLI).

## Проверка работы и восстановление
- **Лог модуля:** `su -c "cat /data/adb/modules/op15_165hz_glo/module.log"`
- **Статус конфига:** `su -c "dumpsys oplusscreenmode | grep -E 'Config\{|isExtremeHighSettingOn'"` (ожидается `mDefaultMaxRate=165.0` и `isExtremeHighSettingOn=true`).
- **Сброс при сбое:** отключите модуль в Safe Mode (KernelSU/Magisk) или удалите `/data/adb/modules/op15_165hz_glo` через recovery/ADB.
- **Ручной откат флагов (если `uninstall.sh` не отработал):**

      su -c "settings put secure choice_mode_rate 120; settings put global app_extreme_high_refresh_switch 0; settings put system peak_refresh_rate 120.0; rm -rf /data/adb/op15_165hz_glo"

## Документация
Принцип работы, таблица `rateId`, поведение LTPO (33–165 Гц) и известные ограничения описаны в [**docs/ARCHITECTURE.md**](docs/ARCHITECTURE.md).
