#!/bin/bash

set -e

# Проверка прав пользователя
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт нужно запускать с правами суперпользователя (sudo)."
   exit 1
fi

# Обновление системы
echo "Обновление системы..."
apt update && apt upgrade -y

# Установка драйверов NVIDIA
echo "Установка драйверов NVIDIA..."
sudo apt install -y nvidia-driver-565 nvidia-prime \
    libnvidia-egl-wayland1 mesa-utils nvtop \
    intel-gpu-tools intel-media-va-driver

# Настройка Wayland для NVIDIA
echo "Настройка Wayland для NVIDIA..."
if ! grep -q '__GLX_VENDOR_LIBRARY_NAME=nvidia' /etc/environment; then
    echo '__GLX_VENDOR_LIBRARY_NAME=nvidia' >> /etc/environment
fi
if ! grep -q 'GBM_BACKEND=nvidia-drm' /etc/environment; then
    echo 'GBM_BACKEND=nvidia-drm' >> /etc/environment
fi
if ! grep -q 'WLR_NO_HARDWARE_CURSORS=1' /etc/environment; then
    echo 'WLR_NO_HARDWARE_CURSORS=1' >> /etc/environment
fi

# Включение Wayland в GDM
echo "Включение Wayland в GDM..."
sed -i '/WaylandEnable=false/s/^/#/' /etc/gdm3/custom.conf || true

# Настройка GNOME для оптимальной работы с Wayland
echo "Настройка GNOME..."
OVERRIDE_FILE="/usr/share/glib-2.0/schemas/99-gnome-triple-buffering.gschema.override"
if [ ! -f "$OVERRIDE_FILE" ]; then
    echo "[org.gnome.mutter]" > $OVERRIDE_FILE
    echo "experimental-features=['scale-monitor-framebuffer']" >> $OVERRIDE_FILE
    glib-compile-schemas /usr/share/glib-2.0/schemas/
fi

# Установка и настройка PipeWire
echo "Установка и настройка PipeWire..."
sudo apt install -y pipewire pipewire-audio-client-libraries
sudo systemctl --user enable pipewire pipewire-pulse
sudo systemctl --user restart pipewire pipewire-pulse

# Включение Force Full Composition Pipeline для NVIDIA
echo "Настройка Force Full Composition Pipeline..."
if command -v nvidia-settings &> /dev/null; then
    nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceCompositionPipeline = On }, nvidia-auto-select +1920+0 { ForceCompositionPipeline = On }"
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
