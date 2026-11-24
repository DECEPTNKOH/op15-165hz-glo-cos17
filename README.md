# OnePlus 15 GLO 165Hz Unlock (ColorOS 17)

Root-модуль (KernelSU / Magisk / APatch) для динамической разблокировки **165 Гц** во всех приложениях и системных анимациях на **OnePlus 15 (GLO, ColorOS 17)**.

- **Автор:** DECEPTNKOH
- **Совместимость:** OnePlus 15 GLO, ColorOS 17 (Android 17)
- **Обновления:** поддерживается автопроверка обновлений в KernelSU / Magisk / APatch (`update.json`)

## Установка
1. Скачайте актуальный ZIP из раздела [**Releases**](https://github.com/DECEPTNKOH/op15-165hz-glo-cos17/releases).
2. Прошейте архив в **KernelSU / Magisk / APatch** и перезагрузите смартфон.
3. В настройках экрана выберите режим **Высокая** или **Автовыбор**.

## Подробности и диагностика
- Принцип работы, таблицы `rateId`, поведение LTPO (33–165 Гц) и известные ограничения описаны в [**docs/ARCHITECTURE.md**](docs/ARCHITECTURE.md).
- Лог работы модуля на устройстве: `/data/adb/modules/op15_165hz_glo/module.log`.
