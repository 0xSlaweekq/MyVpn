#!/bin/bash

set -e

sudo apt update

echo "🔹 System optimization script..."
command_exists() {
    command -v "$1" &> /dev/null
}

echo "🔹 Setting up prime-run script..."
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/prime-run" <<EOL
#!/bin/bash

export gamemoderun
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export WLR_NO_HARDWARE_CURSORS=1
exec "\$@"
EOL
chmod +x "$HOME/.local/bin/prime-run"
source ~/.bashrc

if ! grep -q "alias primerun=" "$HOME/.bashrc"; then
    echo 'alias primerun="$HOME/.local/bin/prime-run"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
else
    echo "primerun alias already exists in .bashrc"
fi

echo "🔹 Installing TLP for power management..."
sudo add-apt-repository -y ppa:linrunner/tlp
sudo apt update
sudo apt install -y tlp tlp-rdw tp-smapi-dkms acpi-call-dkms
sudo apt install -y gamemode cpufrequtils indicator-cpufreq

echo "🔹 Installing auto-cpufreq..."
if ! command_exists auto-cpufreq; then
    ACPU_PATH="/tmp/auto-cpufreq"
    if [ -d "$ACPU_PATH" ]; then
        rm -rf "$ACPU_PATH"
    fi

    git clone https://github.com/AdnanHodzic/auto-cpufreq.git "$ACPU_PATH"
    cd "$ACPU_PATH" && sudo ./auto-cpufreq-installer
    sudo auto-cpufreq --install
    sudo systemctl enable --now auto-cpufreq
    sudo systemctl start auto-cpufreq
    sudo auto-cpufreq --update
    cd "$HOME"
else
    echo "auto-cpufreq is already installed."
fi

echo "🔹 Configuring TLP..."
sudo tee -a /etc/tlp.conf > /dev/null <<EOL
PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=balanced
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=ondemand
CPU_MIN_PERF_ON_AC=5
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=5
CPU_MAX_PERF_ON_BAT=82
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
DISK_APM_LEVEL_ON_AC=255 255
DISK_APM_LEVEL_ON_BAT=255 255
START_CHARGE_THRESH_BAT0=37
STOP_CHARGE_THRESH_BAT0=95
START_CHARGE_THRESH_BAT1=37
STOP_CHARGE_THRESH_BAT1=95
EOL

sudo systemctl enable --now tlp.service
sudo systemctl start tlp.service
sudo /etc/init.d/tlp restart
sudo tlp start

echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl restart cpufrequtils

Install GameMode
echo "🔹 Installing GameMode..."
if ! command_exists gamemoded; then
    GAMEMODE_PATH="/tmp/gamemode"
    if [ -d "$GAMEMODE_PATH" ]; then
        rm -rf "$GAMEMODE_PATH"
    fi

    git clone https://github.com/FeralInteractive/gamemode.git "$GAMEMODE_PATH"
    cd "$GAMEMODE_PATH"
    git checkout 1.8.1
    ./bootstrap.sh
    cd "$HOME"

    systemctl --user enable gamemoded
    systemctl --user start gamemoded
    sudo chmod +x /usr/bin/gamemoderun
    gamemoded -t
else
    echo "GameMode is already installed."
fi

echo "🔹 Installing powertop..."
sudo apt install -y powertop
sudo powertop --auto-tune
sudo systemctl enable fstrim.timer

echo "🔹 System optimization completed successfully!"
echo "🔹 It is recommended to reboot your system to apply all changes."
read -r -p "Would you like to reboot now? (y/n): " RESTART
if [[ $RESTART == "y" || $RESTART == "Y" ]]; then
    sudo reboot
else
    echo "Please reboot your system manually later to apply all changes."
fi
