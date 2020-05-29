#!/bin/bash
# Based on https://github.com/Zren/plasma-applet-todolist/blob/master/run

### Clear SVG cache
rm ~/.cache/plasma-svgelements-*

killall plasmoidviewer

SRC_PATH=`dirname $0`
export QML_DISABLE_DISK_CACHE=true

plasmoidviewer -a "$SRC_PATH/plasmoid" -l topedge -f horizontal -x 0 -y 0

### Test French Locale
# LANG=fr_FR.UTF-8 plasmoidviewer -a "$SRC_PATH/plasmoid" -l topedge -f horizontal -x 0 -y 0
