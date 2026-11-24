# OnePlus 15 GLO 165Hz Unlock (ColorOS 17)

Root-модуль (KernelSU / Magisk / APatch) для динамической разблокировки **165 Гц** во всех приложениях и системных анимациях на **OnePlus 15 (GLO, ColorOS 17)**.

- **Автор:** DECEPTNKOH
- **Совместимость:** OnePlus 15 GLO, ColorOS 17 (Android 17)
- **Обновления:** автопроверка через `update.json` в KernelSU / Magisk / APatch

## Установка
1. Скачайте актуальный ZIP из раздела [**Releases**](https://github.com/DECEPTNKOH/op15-165hz-glo-cos17/releases).
2. Прошейте архив в **KernelSU / Magisk / APatch** и перезагрузите смартфон.
3. В настройках экрана выберите режим **Высокая** или **Автовыбор**.

## Проверка работы и восстановление
- **Лог модуля:** `su -c "cat /data/adb/modules/op15_165hz_glo/module.log"`
- **Статус конфига:** `su -c "dumpsys oplusscreenmode | grep -E 'Config\{|isExtremeHighSettingOn'"` (должно быть `mDefaultMaxRate=165.0` и `isExtremeHighSettingOn=true`).
- **При проблемах:** отключите модуль в Safe Mode (KernelSU/Magisk) или удалите `/data/adb/modules/op15_165hz_glo` через recovery/ADB.

## Документация
Принцип работы, таблица `rateId`, поведение LTPO (33–165 Гц) и известные ограничения описаны в [**docs/ARCHITECTURE.md**](docs/ARCHITECTURE.md).
