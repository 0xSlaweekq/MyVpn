#!/bin/bash

echo "Install NVM & npm"
echo '#################################################################'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
source ~/.bashrc
nvm ls-remote
VERSION=20.13.1
nvm install $VERSION
nvm use $VERSION
nvm alias default $VERSION
sudo chown -R "$USER":"$USER" ~/.npm
sudo chown -R "$USER":"$USER" ~/.nvm
npm i -g pm2@latest nodemon serve
sudo npm i -g pm2@latest nodemon serve
nvm ls

echo '#################################################################'
echo "NVM & npm installed"
echo '#################################################################'
