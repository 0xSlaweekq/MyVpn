#!/bin/bash

APPDIR=~/Applications/cursor
APPIMAGE_URL="https://downloader.cursor.sh/linux/appImage/x64"

wget -O $APPDIR/cursor.AppImage $APPIMAGE_URL
chmod +x $APPDIR/cursor.AppImage
