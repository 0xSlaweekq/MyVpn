#!/bin/bash
set -e

echo "🔹 Installing Cursor AI IDE..."
sudo apt update
sudo apt install -y curl wget dbus-x11

CURSOR_DIR=~/Applications/cursor
echo "🔹 Downloading Cursor AppImage..."
mkdir -p $CURSOR_DIR
wget -O $CURSOR_DIR/cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64"
chmod +x $CURSOR_DIR/cursor.AppImage
sudo ln -s $CURSOR_DIR/cursor.AppImage /usr/local/bin/cursor
wget -O $CURSOR_DIR/cursor.png "https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/utils/cursor/cursor.png"

echo "🔹 Creating .desktop entry for Cursor..."
mkdir -p "~/.local/share/applications"
wget -O ~/.local/share/applications/cursor.desktop "https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/utils/cursor/cursor.desktop"

SYSTEMD_DIR=/etc/systemd/system/
echo "🔹 Creating update script for Cursor..."
wget -O $SYSTEMD_DIR/update-cursor.sh "https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/utils/cursor/update-cursor.sh"
chmod +x $SYSTEMD_DIR/update-cursor.sh

echo "🔹 Creating update service for Cursor..."
mkdir -p $SYSTEMD_DIR
wget -O $SYSTEMD_DIR/update-cursor.service "https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/utils/cursor/update-cursor.service"
sudo systemctl daemon-reload
sudo systemctl enable update-cursor
sudo systemctl start update-cursor
sudo systemctl status update-cursor

xdg-mime default cursor.desktop text/plain
xdg-mime default cursor.desktop application/x-shellscript
xdg-mime default cursor.desktop text/x-script.python
xdg-mime default cursor.desktop text/javascript
xdg-mime default cursor.desktop text/x-c
xdg-mime default cursor.desktop text/x-c++
xdg-mime default cursor.desktop text/x-java

# Set Cursor as default editor for git commit messages
git config --global core.editor "$CURSOR_DIR/cursor.AppImage --wait"

update-desktop-database "~/.local/share/applications"

echo "Adding alias for Cursor..."
BASHRC_FILE="~/.bashrc"
ALIAS_LINE="alias cursor='$CURSOR_DIR/cursor.AppImage --no-sandbox'"

if ! grep -q "alias cursor=" "$BASHRC_FILE"; then
    echo "$ALIAS_LINE" >> "$BASHRC_FILE"
    echo "Alias 'cursor' added to .bashrc"
    echo "You can now run Cursor by typing 'cursor' in terminal after restarting your shell or running 'source ~/.bashrc'"
else
    echo "Alias 'cursor' already exists in .bashrc"
fi

echo "Cursor AI IDE installation complete. You can find it in your application menu."
source "$BASHRC_FILE"
