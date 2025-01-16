#! /usr/bin/env bash

set -e

# Проверка прав пользователя
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт нужно запускать с правами суперпользователя (sudo)."
   exit 1
fi

# Обновление системы
echo "Обновление системы..."
sudo apt update && sudo apt upgrade -y

# Настройка Wayland для NVIDIA
echo "Настройка Wayland для NVIDIA..."
if ! sudo grep -q '__GLX_VENDOR_LIBRARY_NAME=nvidia' /etc/environment; then
    sudo echo '__GLX_VENDOR_LIBRARY_NAME=nvidia' >> /etc/environment
fi
if ! sudo grep -q 'GBM_BACKEND=nvidia-drm' /etc/environment; then
    sudo echo 'GBM_BACKEND=nvidia-drm' >> /etc/environment
fi
if ! sudo grep -q 'WLR_NO_HARDWARE_CURSORS=1' /etc/environment; then
    sudo echo 'WLR_NO_HARDWARE_CURSORS=1' >> /etc/environment
fi

# Включение Wayland в GDM
echo "Включение Wayland в GDM..."
sudo sed -i '/WaylandEnable=false/s/^/#/' /etc/gdm3/custom.conf || true

# Настройка GNOME для оптимальной работы с Wayland
echo "Настройка GNOME..."
OVERRIDE_FILE="/usr/share/glib-2.0/schemas/99-gnome-triple-buffering.gschema.override"
if [ ! -f "$OVERRIDE_FILE" ]; then
    sudo echo "[org.gnome.mutter]" > $OVERRIDE_FILE
    sudo echo "experimental-features=['scale-monitor-framebuffer']" >> $OVERRIDE_FILE
    glib-compile-schemas /usr/share/glib-2.0/schemas/
fi

# Включение Force Full Composition Pipeline для NVIDIA
echo "Настройка Force Full Composition Pipeline..."
if command -v nvidia-settings &> /dev/null; then
    sudo nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceCompositionPipeline = On }, nvidia-auto-select +1920+1080 { ForceCompositionPipeline = On }"
fi

# if ! grep -q 'Identifier "Intel Graphics"' /etc/X11/xorg.conf.d/20-intel.conf; then
#     echo 'Section "Device"
#     Identifier "Intel Graphics"
#     Driver "modesetting"
#     Option "AccelMethod" "glamor"
# EndSection' >> /etc/X11/xorg.conf.d/20-intel.conf
# fi
# if ! grep -q 'Identifier "HDMI-1"' /etc/X11/xorg.conf.d/10-monitor.conf; then
#     echo 'Section "Monitor"
#     Identifier "HDMI-1"
#     Option "PreferredMode" "1920x1080"
#     Option "PreferredRate" "60"
# EndSection' >> /etc/X11/xorg.conf.d/10-monitor.conf
# fi
# if ! grep -q 'Identifier "NVIDIA GPU"' /etc/X11/xorg.conf.d/20-nvidia.conf; then
#     echo 'Section "Device"
#     Identifier "NVIDIA GPU"
#     Driver "nvidia"
#     Option "AllowEmptyInitialConfiguration"
#     Option "Coolbits" "28"
#     Option "TripleBuffer" "true"
#     Option "UseNvKmsCompositionPipeline" "true"
# EndSection

# Section "Screen"
#     Identifier "Screen0"
#     Device "Device0"
#     Option "ForceCompositionPipeline" "true"
#     Option "ForceFullCompositionPipeline" "true"
# EndSection
# ' >> /etc/X11/xorg.conf.d/20-nvidia.conf
# fi
# vblank_mode=0 glxgears
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

# Перезагрузка системы для применения настроек
echo "Скрипт завершён. Перезагрузите систему для применения изменений. Перезагрузить сейчас? (y/n)"
read -r RESTART
if [[ $RESTART == "y" || $RESTART == "Y" ]]; then
    reboot
else
    echo "Перезагрузите систему позже для применения всех настроек."
fi
