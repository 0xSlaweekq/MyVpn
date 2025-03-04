#! /usr/bin/env bash

# dpkg -l | grep linux-image
# srp linux-image-6.13.4-x64v3-xanmod1
# sudo update-grub
# supd

echo "🔹 Install mainline kernel..."
sudo add-apt-repository -y ppa:cappelikan/ppa
sudo apt update
sudo apt install mainline

echo "🔹 Install xanmod kernel..."
wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /etc/apt/keyrings/xanmod-kernel.gpg
echo 'deb [signed-by=/etc/apt/keyrings/xanmod-kernel.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
sudo apt update && sudo apt install -y linux-xanmod-lts-x64v3
# sudo apt install -y \
#     linux-xanmod-rt-x64v3 \
#     linux-xanmod-lts-x64v3 \
#     linux-xanmod-x64v3
sudo update-initramfs -u
sudo update-grub2
sudo update-grub

sudo dpkg --configure -a
sudo apt install -y -f
sudo apt install --fix-broken -y
cat /proc/version

mkdir ~/.local/bin
tee -a ~/.local/bin/prime-run <<< \
'
#!/bin/bash

export gamemoderun
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export WLR_NO_HARDWARE_CURSORS=1
exec "$@"
'
chmod +x ~/.local/bin/prime-run
tee -a ~/.bashrc <<< 'alias primerun="~/.local/bin/prime-run"'
source ~/.bashrc

echo "🔹 Install packages..."
sudo add-apt-repository -y ppa:linrunner/tlp
sudo apt update
sudo apt install -y tlp tlp-rdw tp-smapi-dkms acpi-call-dkms
sudo apt install -y gamemode cpufrequtils indicator-cpufreq tlp

echo "🔹 Install auto-cpufreq..."
ACPU_PATH="/tmp/auto-cpufreq"
git clone https://github.com/AdnanHodzic/auto-cpufreq.git $ACPU_PATH
cd $ACPU_PATH && sudo ./auto-cpufreq-installer
sudo auto-cpufreq --install
# sudo systemctl mask power-profiles-daemon.service
sudo systemctl enable --now auto-cpufreq
sudo systemctl start auto-cpufreq
sudo systemctl status auto-cpufreq
sudo auto-cpufreq --update
cd ~

echo "🔹 Install tlp..."
sudo sh -c 'echo "
PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=balanced
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=ondemand
CPU_MIN_PERF_ON_AC=5
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=5
CPU_MAX_PERF_ON_BAT=70
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
DISK_APM_LEVEL_ON_AC=255 255
DISK_APM_LEVEL_ON_BAT=255 255
START_CHARGE_THRESH_BAT0=37
STOP_CHARGE_THRESH_BAT0=95
START_CHARGE_THRESH_BAT1=37
STOP_CHARGE_THRESH_BAT1=95
" >> /etc/tlp.conf'
sudo systemctl enable --now tlp.service
sudo systemctl start tlp.service
sudo /etc/init.d/tlp restart
sudo tlp start

echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl restart cpufrequtils

echo "🔹 Install Gamemode..."
GAMEMODE_PATH="/tmp/auto-cpufreq"
git clone https://github.com/FeralInteractive/gamemode.git $GAMEMODE_PATH
cd $GAMEMODE_PATH
git checkout 1.8.1 # omit to build the master branch
./bootstrap.sh
cd ~
systemctl --user enable gamemoded && systemctl --user start gamemoded
sudo chmod +x /usr/bin/gamemoderun
gamemoded -t

echo "🔹 Install powertop..."
sudo apt install -y powertop
sudo powertop --auto-tune
sudo systemctl enable fstrim.timer

echo "🔹 Swap on 32GB..."
sudo swapon --show
sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile bs=1M count=32768 oflag=append conv=notrunc
sudo mkswap /swapfile
sudo swapon /swapfile

echo "All done. Recommendation reboot system, now? (Y/n)"
read -r RESTART
if [[ $RESTART == "y" || $RESTART == "Y" ]]; then
    reboot
else
    echo "Reboot system manual after"
fi


# Liquorix Kernel:
# curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
# sudo add-apt-repository ppa:liquorix-team/liquorix
# sudo apt update
# sudo apt install linux-image-liquorix-amd64

# Zen Kernel:
# sudo add-apt-repository ppa:teejee2008/ppa
# sudo apt update
# sudo apt install linux-zen

# mainline kernel
# sudo add-apt-repository ppa:teejee2008/ppa
# sudo apt update
# sudo apt install ukuu
# ukuu --install-latest
