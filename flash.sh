#!/bin/bash -e

FASTBOOT=platform-tools/fastboot

PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [ ! -f $FASTBOOT ]; then
    rm -rf platform-tools
    rm -f platform-tools-latest-$PLATFORM.zip

    curl -L https://dl.google.com/android/repository/platform-tools-latest-$PLATFORM.zip --output platform-tools-latest-$PLATFORM.zip
    unzip platform-tools-latest-$PLATFORM.zip

    rm -f platform-tools-latest-$PLATFORM.zip
fi

if [ ota-signed-latest.zip -nt files/system.img ]; then
  unzip -o ota-signed-latest.zip
  touch files/system.img
fi

sudo $FASTBOOT oem 4F500301 || true
sudo $FASTBOOT flash recovery recovery.img

# from OTA
[ -f files/logo.bin ] && $FASTBOOT flash LOGO files/logo.bin
sudo $FASTBOOT flash:raw boot boot.img
sudo $FASTBOOT flash system files/system.img

# clear userdata
sudo $FASTBOOT erase userdata
sudo $FASTBOOT format cache
sudo $FASTBOOT reboot
