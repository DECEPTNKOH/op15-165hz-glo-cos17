VERSION=$(grep '^version=' "$MODPATH/module.prop" | cut -d'=' -f2 | tr -d '\r')
DEVICE=$(getprop ro.product.device)
MODEL=$(getprop ro.product.model)
FORCE_FLAG=0

if [ "${FORCE_INSTALL:-0}" = "1" ] || [ -f "/data/local/tmp/force_op15_165hz" ]; then
  FORCE_FLAG=1
fi

ui_print "========================================="
ui_print " OnePlus 15 GLO 165Hz Unlock (ColorOS 17)"
ui_print " Author: DECEPTNKOH | Version: $VERSION"
ui_print "========================================="

if [ "$DEVICE" != "OP611FL1" ] && [ "$MODEL" != "CPH2747" ]; then
  if [ "$FORCE_FLAG" != "1" ]; then
    abort "! Несовместимое устройство: $MODEL ($DEVICE). Ожидается OnePlus 15 GLO (CPH2747 / OP611FL1). Для обхода создайте /data/local/tmp/force_op15_165hz."
  else
    ui_print "! Принудительная установка на $MODEL ($DEVICE)"
  fi
fi

SRC_RR="/my_product/etc/refresh_rate_config.xml"
if [ ! -f "$SRC_RR" ]; then
  if [ "$BOOTMODE" = "true" ]; then
    abort "! Не найден $SRC_RR. Модуль предназначен для ColorOS 17."
  else
    ui_print "! Внимание: /my_product не смонтирован (установка из recovery). Проверка пропущена."
  fi
else
  ui_print "- Конфиги дисплея найдены"
  if [ "$FORCE_FLAG" != "1" ]; then
    if ! grep -q 'extremeHighEnable' "$SRC_RR" || ! grep -q 'rateId="7"' "$SRC_RR"; then
      abort "! В $SRC_RR не найдена поддержка 165 Гц (extremeHighEnable / rateId=\"7\")."
    fi
  fi
fi

STATE_DIR="/data/adb/op15_165hz_glo"
mkdir -p "$STATE_DIR"
if [ ! -f "$STATE_DIR/orig_settings.env" ] && [ -f "/data/adb/modules/op15_165hz_glo/orig_settings.env" ]; then
  cp -f "/data/adb/modules/op15_165hz_glo/orig_settings.env" "$STATE_DIR/orig_settings.env"
fi

ui_print "- Настройка прав доступа..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
ui_print "- Установка завершена. Перезагрузите устройство."
