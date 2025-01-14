#!/bin/bash
# curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash


wget -qO - https://dl.xanmod.org/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/xanmod-kernel.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/xanmod-kernel.gpg] http://deb.xanmod.org releases main" >> /etc/apt/sources.list.d/xanmod-kernel.list'
sudo apt update && sudo apt install -y linux-xanmod-x64v3

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
exec "$@"
'
chmod +x ~/.local/bin/prime-run
tee -a ~/.bashrc <<< 'alias primerun="~/.local/bin/prime-run"'
source ~/.bashrc

# Install packages for gnome
# sudo apt install -y power-profiles-daemon
# powerprofilesctl set performance && powerprofilesctl list
# Install packages
sudo add-apt-repository -y ppa:linrunner/tlp
sudo apt update
sudo apt install -y tlp tlp-rdw tp-smapi-dkms acpi-call-dkms
sudo apt install -y gamemode cpufrequtils indicator-cpufreq tlp

# Install auto-cpufreq
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
sudo auto-cpufreq --install
# sudo systemctl mask power-profiles-daemon.service
sudo systemctl enable --now auto-cpufreq
sudo systemctl start auto-cpufreq
sudo systemctl status auto-cpufreq
sudo auto-cpufreq --update
cd ~ && rm -rf auto-cpufreq

# Install tlp
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

# Install Gamemode
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode
git checkout 1.8.1 # omit to build the master branch
./bootstrap.sh
cd ~ && rm -rf ./gamemode
systemctl --user enable gamemoded && systemctl --user start gamemoded
sudo chmod +x /usr/bin/gamemoderun
gamemoded -t

# sudo nano /usr/share/gamemode/gamemode.ini
# [gpu]
# apply_gpu_optimisations = 1
# systemctl --user restart gamemoded
# mkdir -p ~/.config/systemd/user
# nano ~/.config/systemd/user/gamemode-gnome.service
# [Unit]
# Description=GameMode for GNOME Shell
# After=graphical.target

# [Service]
# ExecStart=/usr/bin/gamemoded
# Restart=always

# [Install]
# WantedBy=default.target


sudo apt install -y powertop
sudo powertop --auto-tune
sudo systemctl enable fstrim.timer

# Настройка intel_pstate для гибридной архитектуры
echo "Настройка intel_pstate..."
if ! grep -q "intel_pstate=enable" /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_pstate=enable"/' /etc/default/grub
    sudo update-grub
fi

# Перезагрузка системы
echo "Скрипт завершён. Рекомендуется перезагрузить систему для применения изменений. Перезагрузить сейчас? (y/n)"
read -r RESTART
if [[ $RESTART == "y" || $RESTART == "Y" ]]; then
    reboot
else
    echo "Перезагрузите систему позже для применения всех настроек."
fi
