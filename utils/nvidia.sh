#!/bin/bash

echo 'Installing Nvidia & other graphics drivers'
echo '#################################################################'
cd ~
# For remove all nvidia drivers
sudo rm -rf /etc/modprobe.d/nvidia.conf /etc/modprobe.d/blacklist-nvidia.conf \
  /etc/modprobe.d/blacklist-nvidia-nouveau.conf
sudo apt remove --purge -y '^nvidia-.*'
sudo apt remove --purge -y '^cuda-.*'
sudo apt autoremove $(dpkg -l *nvidia* |grep ii |awk '{print $2}') -y
sudo apt autoremove $(dpkg -l *cuda* |grep ii |awk '{print $2}') -y
sudo nvidia-installer --uninstall
sudo update-initramfs -u

sudo apt install -y \
  linux-headers-$(uname -r) clang gcc make acpid build-essential \
  ca-certificates dirmngr software-properties-common apt-transport-https \
  curl dkms libglvnd0 libc-dev freeglut3-dev pkg-config libglvnd-dev \
  libegl-dev libegl1 libgl-dev libgl1 libx11-dev libxmu-dev libxi-dev \
  libglu1-mesa-dev libfreeimage-dev libglfw3-dev libgles-dev libgles1 \
  libglvnd-core-dev libglx-dev libopengl-dev

sudo apt install software-properties-gtk # for kde qt, for gnome gtk

# sudo add-apt-repository -y ppa:graphics-drivers/ppa
# sudo add-apt-repository -y ppa:oibaf/graphics-drivers
sudo dpkg --add-architecture i386
sudo apt update
sudo apt full-upgrade -y

sudo apt install --reinstall -y xserver-xorg-video-all xserver-xorg-video-nouveau \
  xserver-xorg-video-intel xserver-xorg-video-nvidia-565
sudo apt-key del 7fa2af80
sudo apt install -y nvidia-driver-565 nvidia-headless-565 nvidia-dkms-565
sudo apt install -y nvidia-settings nvidia-prime \
  libnvidia-egl-wayland1
sudo ubuntu-drivers install nvidia-headless-565 nvidia-dkms-565 nvidia-driver-565

sudo apt install -y \
  libvulkan1:{i386,amd64} mesa-vulkan-drivers:{i386,amd64} libgl1-mesa-dri:{i386,amd64} \
  vkbasalt libglu1-mesa-dev:{i386,amd64} freeglut3-dev mesa-common-dev \
  libopenal1 libopenal-dev libalut0 libalut-dev

# sudo tee -a /etc/sddm.conf.d/kde_settings.conf <<< \
# '
# [Wayland]
# EnableWayland=true
# Session=plasmawayland
# '
sudo prime-select on-demand # nvidia|intel|on-demand|query
sudo nvidia-xconfig --prime
sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
sudo bash -c "echo blacklist nouveau >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo systemctl daemon-reload

# Update GRUB и initramfs
sudo update-initramfs -u
sudo update-grub2

/usr/bin/nvidia-persistenced --verbose
sudo systemctl enable nvidia-persistenced
sudo systemctl start nvidia-persistenced
sudo systemctl status nvidia-persistenced
cat /proc/driver/nvidia/version
# nvidia-smi
# echo $XDG_SESSION_TYPE
echo '#################################################################'

# cd ~
# wget https://download.nvidia.com/XFree86/Linux-x86_64/565.77/NVIDIA-Linux-x86_64-565.77.run
# chmod 700 NVIDIA-*.run
# sudo telinit 3
# sudo ./NVIDIA-*.run
# sudo telinit 5
# sudo systemctl restart graphical.target
