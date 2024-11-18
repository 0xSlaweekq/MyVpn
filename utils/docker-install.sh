#!/bin/bash

echo '#### Installing Docker'
echo '#################################################################'
if [[ $(which docker) && $(docker --version) && $(docker compose) ]]; then
   echo 'Docker installed, continue...'
else
echo 'Docker NOT installed, continue...'
sudo apt autoremove $(dpkg -l *docker* |grep ii |awk '{print $2}') -y
sudo apt install -y ca-certificates curl gnupg lsb-release

curl -sSL https://get.docker.com | sh &&\
  sudo usermod -aG docker $(whoami) &&\
  sudo gpasswd -a $USER docker

sudo systemctl restart docker
sudo systemctl enable --now \
  docker docker.service docker.socket containerd containerd.service
sudo systemctl daemon-reload

source ~/.bashrc
echo '#################################################################'
echo '#### Docker installed'
echo '#################################################################'
fi

# sudo apt -y -qq install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin
# deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable
