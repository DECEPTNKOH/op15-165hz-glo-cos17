ui_print "========================================="
ui_print " OnePlus 15 GLO 165Hz Unlock (ColorOS 17)"
ui_print " Version: v1.5.0"
ui_print "========================================="

if [ ! -f /my_product/etc/refresh_rate_config.xml ]; then
  abort "! Не найден /my_product/etc/refresh_rate_config.xml. Модуль предназначен для ColorOS 17."
fi

ui_print "- Конфиги дисплея найдены"
ui_print "- Настройка прав доступа..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
ui_print "- Установка завершена. Перезагрузите устройство."
