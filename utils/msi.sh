#!/usr/bin/env bash
set -e

echo "🔹 Installing MSI EC (Battery Charge Control)..."
if ! dkms status | grep -q "msi_ec"; then
  sudo apt update
  sudo apt install -y git build-essential dkms

  # Clone repository with proper error handling
  if [ -d "/tmp/msi-ec" ]; then
    sudo rm -rf /tmp/msi-ec
  fi

  sudo git clone https://github.com/BeardOverflow/msi-ec.git /tmp/msi-ec || {
    echo "Failed to clone msi-ec repository. Exiting."
    exit 1
  }

  cd /tmp/msi-ec || {
    echo "Failed to enter /tmp/msi-ec directory. Exiting."
    exit 1
  }

  sudo make dkms-install || {
    echo "Failed to install MSI EC module. Exiting."
    exit 1
  }

  cd "$HOME" || exit 1
else
  echo "...MSI EC module already installed, skipping..."
fi

echo "🔹 Create automatic MSI battery charge control..."
if [ -f "/usr/local/bin/msi_battery_control.sh" ]; then
  sudo rm -f /usr/local/bin/msi_battery_control.sh
fi

sudo tee /usr/local/bin/msi_battery_control.sh > /dev/null <<EOL
#!/bin/bash
while true; do
  charge_level=\$(cat /sys/class/power_supply/BAT0/capacity)
  if [ "\$charge_level" -ge 97 ]; then
    echo "Charge disabled!"
    sudo msi-ec -w 0x2F 0
  elif [ "\$charge_level" -le 30 ]; then
    echo "Charge enabled!"
    sudo msi-ec -w 0x2F 1
  fi
  sleep 60
done
EOL

sudo chmod +x /usr/local/bin/msi_battery_control.sh

echo "🔹 Setting up automatic battery charge control..."
if [ -f "/etc/systemd/system/msi-battery.service" ]; then
  sudo rm -f /etc/systemd/system/msi-battery.service
fi

sudo tee /etc/systemd/system/msi-battery.service > /dev/null <<EOL
[Unit]
Description=MSI Smart Battery Control
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/msi_battery_control.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

echo "🔹 Enable and start the service..."
sudo systemctl daemon-reload
sudo systemctl enable msi-battery.service
sudo systemctl start msi-battery.service

echo "🔹 Installing Qt 6.8.2 build dependencies..."
sudo apt update
sudo apt install -y build-essential perl python3 cmake ninja-build libclang-dev \
  libgl1-mesa-dev libglu1-mesa-dev libvulkan-dev libxkbcommon-dev libxkbcommon-x11-dev \
  libx11-dev libxcb1-dev libxcb-cursor-dev libxcb-glx0-dev libxcb-icccm4-dev \
  libxcb-image0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-render0-dev \
  libxcb-render-util0-dev libxcb-shape0-dev libxcb-shm0-dev libxcb-sync-dev \
  libxcb-util-dev libxcb-xfixes0-dev libxcb-xinerama0-dev libxcb-xkb-dev \
  libxext-dev libxi-dev libxrender-dev libfontconfig1-dev libfreetype6-dev \
  libglib2.0-dev libicu-dev libjpeg-dev libpng-dev libssl-dev zlib1g-dev


echo "🔹 Downloading Qt 6.8.2 source code..."
if [ ! -f "/tmp/qt-everywhere-src-6.8.2.tar.xz" ]; then
  sudo wget -c "https://download.qt.io/official_releases/qt/6.8/6.8.2/single/qt-everywhere-src-6.8.2.tar.xz" -O /tmp/qt-everywhere-src-6.8.2.tar.xz || {
    echo "Failed to download Qt source code. Skipping installation."
    exit 1
  }
fi

echo "🔹 Extracting Qt 6.8.2 source code..."
if [ -d "/tmp/qt-everywhere-src-6.8.2" ]; then
  sudo rm -rf /tmp/qt-everywhere-src-6.8.2
fi
sudo tar -xf /tmp/qt-everywhere-src-6.8.2.tar.xz -C /tmp || {
  echo "Failed to extract Qt source code. Skipping installation."
  exit 1
}

echo "🔹 Building Qt 6.8.2 (this will take a while)..."
if [ -d "/tmp/qt-build" ]; then
  sudo rm -rf /tmp/qt-build
fi
mkdir -p /tmp/qt-build
cd /tmp/qt-build || { echo "Failed to create build directory"; exit 1; }

sudo /tmp/qt-everywhere-src-6.8.2/configure -prefix /usr/local/Qt-6.8.2 \
  -release -opensource -confirm-license

make -j$(nproc)
sudo make install

if [ -d "/usr/local/Qt-6.8.2" ]; then
  echo "🔹 Setting up Qt 6.8.2 environment..."
  if [ -f "/etc/profile.d/qt6.sh" ]; then
    echo "Qt6 environment file already exists, skipping..."
  else
    sudo tee /etc/profile.d/qt6.sh > /dev/null <<EOL
export PATH=/usr/local/Qt-6.8.2/bin:\$PATH
export LD_LIBRARY_PATH=/usr/local/Qt-6.8.2/lib:\$LD_LIBRARY_PATH
export QT_PLUGIN_PATH=/usr/local/Qt-6.8.2/plugins
export QML2_IMPORT_PATH=/usr/local/Qt-6.8.2/qml
EOL
  fi
  sudo ldconfig

  export PATH=/usr/local/Qt-6.8.2/bin:$PATH
  export LD_LIBRARY_PATH=/usr/local/Qt-6.8.2/lib:$LD_LIBRARY_PATH
  export QT_PLUGIN_PATH=/usr/local/Qt-6.8.2/plugins
  export QML2_IMPORT_PATH=/usr/local/Qt-6.8.2/qml
fi
cd ~

if command -v mcontrolcenter &> /dev/null; then
    echo "MControlCenter already installed, skipping..."
else
    echo "🔹 Installing MControlCenter..."
    if [ ! -f "/tmp/MControlCenter.tar.gz" ]; then
        sudo wget -c "https://github.com/dmitry-s93/MControlCenter/releases/download/0.5.0/MControlCenter-0.5.0-bin.
        tar.gz" -O /tmp/MControlCenter.tar.gz || {
          echo "Failed to download MControlCenter. Skipping installation."
          exit 1
        }
    fi
    if [ -d "/tmp/MControlCenter-0.5.0-bin" ]; then
       sudo rm -rf /tmp/MControlCenter-0.5.0-bin
    fi
    sudo tar -xzf /tmp/MControlCenter.tar.gz -C /tmp || {
        echo "Failed to extract MControlCenter archive. Skipping installation."
        exit 1
    }

    cd /tmp/MControlCenter-0.5.0-bin || {
        echo "Failed to enter MControlCenter directory. Exiting."
        exit 1
    }

    sudo ./install.sh || {
        echo "Failed to install MControlCenter. Exiting."
        exit 1
    }

    cd "$HOME" || exit 1
fi

echo "🔹 Installation completed successfully!"
echo "🔹 You can now run MControlCenter by typing 'mcontrolcenter' in terminal or finding it in your applications menu."
