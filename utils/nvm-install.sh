#!/bin/bash

echo "Install NVM & npm"
echo '#################################################################'
# Install nvm
cd ~
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Get nvm in current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

nvm ls-remote

# Install and use v20.13.1 Node.js
VERSION=22.12.0
nvm install "$VERSION"
nvm use "$VERSION"
nvm alias default "$VERSION"

# Install npm packages
npm i -g npm@11.0.0
npm i -g pm2 nodemon serve \
  yarn corepack prettier eslint solhint prettier solidity-code-metrics \
  dotenv nx nestjs @nestjs/cli nest-cli nats solc npm-check-updates \
  tronbox
corepack enable

# Check installed versions Node.js
nvm ls

echo '#################################################################'
echo "NVM & npm installed"
echo '#################################################################'
