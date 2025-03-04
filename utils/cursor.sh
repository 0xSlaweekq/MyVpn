#!/usr/bin/bash

installCursor() {
    if ! [ -f /opt/cursor.appimage ]; then
        echo "Installing Cursor AI IDE..."

        # Install curl if not installed
        if ! command -v curl &> /dev/null; then
            echo "curl is not installed. Installing..."
            sudo apt-get update
            sudo apt-get install -y curl
        fi

        # Download Cursor AppImage
        echo "Downloading Cursor AppImage..."
        sudo curl -L https://downloader.cursor.sh/linux/appImage/x64 -o /opt/cursor.appimage
        sudo chmod +x /opt/cursor.appimage

        # Download Cursor icon
        echo "Downloading Cursor icon..."
        sudo curl -L https://raw.githubusercontent.com/rahuljangirwork/copmany-logos/refs/heads/main/cursor.png -o /opt/cursor.png

        # Create a .desktop entry for Cursor
        echo "Creating .desktop entry for Cursor..."
        mkdir -p "$HOME/.local/share/applications"
        bash -c "cat > $HOME/.local/share/applications/cursor.desktop" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=/opt/cursor.appimage --no-sandbox
Icon=/opt/cursor.png
Terminal=false
Type=Application
Categories=Development;
MimeType=text/plain;
EOL

        xdg-mime default cursor.desktop text/plain
        update-desktop-database "$HOME/.local/share/applications"

        echo "Adding alias for Cursor..."
        BASHRC_FILE="$HOME/.bashrc"
        ALIAS_LINE="alias cursor='/opt/cursor.appimage --no-sandbox'"

        if ! grep -q "alias cursor=" "$BASHRC_FILE"; then
            echo "$ALIAS_LINE" >> "$BASHRC_FILE"
            echo "Alias 'cursor' added to .bashrc"
            echo "You can now run Cursor by typing 'cursor' in terminal after restarting your shell or running 'source ~/.bashrc'"
        else
            echo "Alias 'cursor' already exists in .bashrc"
        fi

        echo "Cursor AI IDE installation complete. You can find it in your application menu."
    else
        echo "Cursor AI IDE is already installed."
    fi
}

installCursor
