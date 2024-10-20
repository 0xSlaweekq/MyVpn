#!/bin/bash

echo "Installing Docker"
echo '#################################################################'
if [[ $(which docker) && $(docker --version) && $(docker compose) ]]; then
   echo 'Docker installed, continue...'
else
echo 'Docker NOT installed, continue...'
sudo apt autoremove $(dpkg -l *docker* |grep ii |awk '{print $2}') -y

curl -sSL https://get.docker.com | sh &&\
  sudo usermod -aG docker $(whoami) &&\
  sudo gpasswd -a $USER docker

sudo systemctl restart docker
sudo systemctl enable --now \
  docker docker.service docker.socket containerd containerd.service
sudo systemctl daemon-reload

echo '#################################################################'
echo 'Docker installed'
echo '#################################################################'
fi
