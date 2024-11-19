#!/bin/bash
# curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

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
export __VK_LAYER_NV_optimus=NVIDIA_only
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
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
DISK_APM_LEVEL_ON_AC="255 255"
DISK_APM_LEVEL_ON_BAT="255 255"
START_CHARGE_THRESH_BAT0=40
STOP_CHARGE_THRESH_BAT0=95
START_CHARGE_THRESH_BAT1=40
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
