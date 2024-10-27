#!/bin/bash

echo 'Installing Nvidia & other graphics drivers'
echo '#################################################################'
cd ~
# For remove all nvidia drivers
sudo rm -rf /etc/X11/xorg.conf /etc/X11/xorg.conf-external-display /etc/modprobe.d/nvidia.conf \
  /etc/modprobe.d/blacklist-nvidia.conf /etc/modprobe.d/blacklist-nvidia-nouveau.conf \
  /etc/systemd/system/nvidia-persistenced.service
sudo apt autoremove $(dpkg -l *nvidia* |grep ii |awk '{print $2}') -y
# Get the release version of Ubuntu => 2404
RELEASE_VERSION=$(lsb_release -rs | sed 's/\([0-9]\+\)\.\([0-9]\+\)/\1\2/')

# Download and install CUDA package for Ubuntu
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${RELEASE_VERSION}/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
rm cuda-keyring_1.1-1_all.deb

sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo dpkg --add-architecture i386
sudo apt update
sudo apt full-upgrade -y

sudo apt install software-properties-qt # for kde qt, for gnome gtk
sudo apt install --reinstall -y xserver-xorg-video-all xserver-xorg-video-nouveau \
  xserver-xorg-video-intel xserver-xorg-video-nvidia-555
sudo apt install -y \
  linux-headers-$(uname -r) clang gcc make acpid build-essential \
  ca-certificates dirmngr software-properties-common apt-transport-https \
  curl dkms libglvnd-core-dev libglvnd0 libglvnd-dev libc-dev freeglut3-dev \
  libx11-dev libxmu-dev libxi-dev libglu1-mesa-dev libfreeimage-dev \
  libglfw3-dev
sudo apt-key del 7fa2af80
sudo apt install -y nvidia-driver-555 nvidia-headless-555 nvidia-dkms-555
sudo apt install -y nvidia-settings nvidia-prime
sudo ubuntu-drivers install nvidia-headless-555 nvidia-dkms-555 nvidia-driver-555

sudo apt install -y \
  libvulkan1:{i386,amd64} mesa-vulkan-drivers:{i386,amd64} libgl1-mesa-dri:{i386,amd64} \
  vkbasalt libglu1-mesa-dev:{i386,amd64} freeglut3-dev mesa-common-dev \
  libopenal1 libopenal-dev libalut0 libalut-dev

# Update and upgrade the system again to ensure all packages are installed correctly
sudo apt update
# apt list cuda-toolkit-* | grep -v config
sudo apt install -y cuda
sudo apt install -y cuda-toolkit nvidia-cuda-toolkit nvidia-gds
/usr/local/cuda/bin/nvcc --version

echo 'export PATH="/usr/bin:/bin:$PATH/usr/local/cuda/bin\${PATH:+:\${PATH}}"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
' >> ~/.bashrc
source ~/.bashrc

sudo prime-select on-demand # nvidia|intel|on-demand|query
sudo nvidia-xconfig --prime
sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
sudo bash -c "echo blacklist nouveau >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo systemctl daemon-reload

# Update grub2 conf
sudo update-grub2
# Update initramfs
sudo update-initramfs -u

/usr/bin/nvidia-persistenced --verbose
sudo systemctl enable nvidia-persistenced
sudo systemctl start nvidia-persistenced
sudo systemctl status nvidia-persistenced
cat /proc/driver/nvidia/version

echo '#################################################################'


# cd ~
# wget https://download.nvidia.com/XFree86/Linux-x86_64/550.107.02/NVIDIA-Linux-x86_64-550.107.02.run
# chmod 700 NVIDIA-*.run
# sudo telinit 3
# sudo ./NVIDIA-*.run
# sudo telinit 5
# systemctl restart graphical.target
