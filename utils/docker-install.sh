#! /usr/bin/env bash

echo '#### Installing Docker'
echo '#################################################################'

if command -v docker &> /dev/null && docker --version &> /dev/null && docker compose version &> /dev/null; then
    echo 'Docker and Docker Compose are already installed. Continuing...'
else
    echo 'Docker not found. Installing Docker...'
    sudo apt autoremove $(dpkg -l *docker* |grep ii |awk '{print $2}') -y
    sudo apt remove --purge -y '^docker*' '^containerd*'
    sudo apt autoremove -y

    sudo apt update && sudo apt install -y \
        ca-certificates curl gnupg lsb-release

    curl -sSL https://get.docker.com | sh &&\
      sudo usermod -aG docker $(whoami) &&\
      sudo gpasswd -a $USER docker

    sudo systemctl restart docker
    sudo systemctl enable --now \
      docker docker.service docker.socket containerd containerd.service
    sudo systemctl daemon-reload
    . ~/.bashrc

    echo '#################################################################'
    echo '#### Docker installed successfully'
    echo "Please log out and log back in for group changes to take effect."
    echo '#################################################################'
fi
