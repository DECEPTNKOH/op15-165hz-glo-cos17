# Архитектура и принцип работы 165 Гц на OnePlus 15 (GLO, ColorOS 17)

Документ описывает реальную механику управления частотой обновления экрана в ColorOS 17 на OnePlus 15 (получено на основе системных конфигов `/my_product/etc/`, `dumpsys display`, `dumpsys SurfaceFlinger` и `dumpsys oplusscreenmode`).

---

## 1. Аппаратные режимы дисплея и таблица `rateId`

Панель OnePlus 15 (`1272x2772` / `1080x2354`) поддерживает 5 базовых частот. В конфиге `/my_product/etc/refresh_rate_config.xml` они кодируются через `rateId`:

| `rateId` | Частота | `sfModeId` (QHD) | Примечание |
| :--- | :--- | :--- | :--- |
| `0` | По умолчанию | — | Unspecified |
| `1` | 90 Гц | `2` | — |
| `2` | 60 Гц | `1` | Режим «Стандартная» |
| `3` | 120 Гц | `0` | Базовый режим (LTPO 1–120 Гц) |
| `4` | 144 Гц | `4` | Игровой/промежуточный режим |
| `7` | **165 Гц** | `5` | Режим `extremeHighRate` |

В `<config>` и `<item>` используется 4-позиционная строка формата `Авто-90-60-Высокая` (например, `7-1-2-7`), а в тегах `<extremeHighRate>` — одиночный ID (`rateId="7"`).

---

## 2. Почему стоковая прошивка ограничивает 165 Гц

В стоке 165 Гц разрешены только для короткого белого списка (`<extremeHighRate>`: WhatsApp, Instagram, X, Facebook, WeChat, QQ и др.). Все остальные приложения и система упираются в 4 уровня ограничений:

1. **Глобальные лимиты в `/my_product/etc/refresh_rate_config.xml`:**
   - `defaultRateId="1-1-2-3"` (потолок 120 Гц для всех приложений вне списка).
   - `maxrefreshsettings="3"` и `mDefaultMaxRate=120.0`.
   - `enableAppSwitchBoost="true"` (`appSwitchBoostType="2"`) — при переключении окон и жесте свайпа вверх активирует `PRIORITY_START_ANIMATION_BOOST -> 120.0`.
2. **Движок системных анимаций `/my_product/etc/sys_dynamic_frame_config.xml`:**
   - Принудительно задаёт `targetFramerate="120"` для скролла (`10001`/`10003`), клавиатуры (`20103`), окон и анимаций лаунчера/«Недавних» (`type="20201"`).
3. **Системные флаги Android (`settings`):**
   - `secure choice_mode_rate=120`
   - `global app_extreme_high_refresh_switch=0` (`isExtremeHighSettingOn=false` в `oplusscreenmode`)
4. **Приоритеты голосования в `RefreshRateCore` (`oplusscreenmode`):**
   - `PRIORITY_START_ANIMATION_BOOST` (выше, чем окно) — снимается через `enableAppSwitchBoost="false"`.
   - `PRIORITY_LAUNCHER_REQUEST` (выше, чем окно) — отправляется процессом `com.android.launcher` (`OplusLauncher.apk`).
   - `PRIORITY_WINDOW_REQUEST` — формируется из `refresh_rate_config.xml`.

---

## 3. Что именно делает модуль

Модуль **не хранит статических системных файлов** — он динамически патчит оригинальные конфиги вашей текущей сборки при каждой загрузке, поэтому устойчив к минорным OTA-обновлениям.

### `post-fs-data.sh` (выполняется до старта `system_server`)
1. Копирует оригинальные файлы из `/my_product/etc/` в `$MODDIR/patched/`.
2. В `refresh_rate_config.xml`:
   - Меняет `defaultRateId` на `7-1-2-7`, `maxrefreshsettings` на `7`, `disableViewOverrideDefault` на `true`, добавляет `defaultMaxRate="165"`.
   - Отключает `enableAppSwitchBoost="false"` (убирает `PRIORITY_START_ANIMATION_BOOST -> 120.0`).
   - Переводит все 4-значные `rateId` приложений (кроме строк с камерой) на `7-1-2-7`.
   - Добавляет `com.android.launcher` и `com.android.systemui` в `<extremeHighRate>`.
3. В `sys_dynamic_frame_config.xml`:
   - Заменяет `targetFramerate="120"` на `targetFramerate="165"`.
4. Восстанавливает права `0644`, владельца `0:0` и оригинальный SELinux-контекст (`u:object_r:system_file:s0`), после чего монтирует файлы через `mount --bind`.

### `service.sh` (выполняется после `sys.boot_completed=1`)
Выставляет системные флаги:
- `settings put secure choice_mode_rate 165`
- `settings put global app_extreme_high_refresh_switch 1` (`isExtremeHighSettingOn=true`)
- `settings put system peak_refresh_rate 165.0`

### `uninstall.sh`
При удалении модуля возвращает `choice_mode_rate=120`, `app_extreme_high_refresh_switch=0` и `peak_refresh_rate=120.0`.

---

## 4. Аппаратные и системные ограничения (без LSPosed)

- **LTPO 33–165 Гц:** в `modeId 5` (`165.00 Hz`) SurfaceFlinger и драйвер дисплея (`/sys/kernel/oplus_display/min_fps = 33`) используют целые делители: `165 → 82.5 → 55 → 41.25 → 33 Гц`. Полноценный LTPO `1–10 Гц` в прошивке привязан к `modeId 0` (`120 Гц`, `sf_framerate_ranges: 120..10` в `oplus_vrr_config.json`).
- **«Недавние» с рабочего стола:** при свайпе вверх *из приложений* держится стабильно `165 Гц`. При свайпе *с главного экрана* `OplusLauncher.apk` на 1–2 секунды отправляет `PRIORITY_LAUNCHER_REQUEST -> 120.0`, после чего частота возвращается на `165 Гц`. Поскольку `PRIORITY_LAUNCHER_REQUEST` приоритетнее `PRIORITY_WINDOW_REQUEST`, убрать эти 1–2 секунды можно только хуком через LSPosed или патчем `OplusLauncher.apk`.
- **Камера:** `com.oplus.camera` не регулируется через `refresh_rate_config.xml`. Видоискатель ограничен 60 Гц на уровне приложения/HAL; видеозапись 120 FPS работает штатно.
- **Игры:** встроенный Game Space может отдельно ограничивать FPS — для 165 Гц в играх требуется отключать контроль частоты в Game Space или патчить профили игр.
