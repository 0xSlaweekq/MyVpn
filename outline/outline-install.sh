#!/bin/bash

echo "Installing Outline"
echo '#################################################################'
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 22/tcp
sudo ufw allow 39885/tcp
sudo ufw allow 1586/tcp
sudo ufw allow 1586/udp

sudo wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh | bash

echo '#################################################################'
echo "Outline installed"
echo '#################################################################'
