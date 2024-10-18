#!/bin/bash

echo "Install NVM & npm"
echo '#################################################################'
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Get nvm in current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# List of availible versions Node.js
nvm ls-remote

# Install and use v20.13.1 Node.js
VERSION=20.13.1
nvm install $VERSION
nvm use $VERSION
nvm alias default $VERSION

# Install npm package
npm i -g pm2@latest nodemon serve
sudo npm i -g pm2@latest nodemon serve

# Check installed versions Node.js
nvm ls

echo '#################################################################'
echo "NVM & npm installed"
echo '#################################################################'
