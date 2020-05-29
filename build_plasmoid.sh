#!/usr/bin/env bash
# Based on the original script from https://github.com/Zren/plasma-applet-todolist/blob/master/build

set -e

PLASMOID_DIR=`dirname $0`/plasmoid
plasmoidName="com.librehat.yapstocks"
plasmoidVersion=$(grep "X-KDE-PluginInfo-Version" $PLASMOID_DIR/metadata.desktop | cut -d "=" -f 2)  # kreadconfig5 doesn't work on my system somehow
filename="${plasmoidName}-v${plasmoidVersion}.plasmoid"
cd $PLASMOID_DIR
zip -r $filename *
cd -
mkdir -p dist
mv $PLASMOID_DIR/$filename dist/$filename
echo "md5: $(md5sum dist/$filename | awk '{ print $1 }')"
echo "sha256: $(sha256sum dist/$filename | awk '{ print $1 }')"
