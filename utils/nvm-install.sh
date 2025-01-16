#! /usr/bin/env bash

echo "Install NVM & npm"
echo '#################################################################'
# Install nvm
cd ~
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Get nvm in current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
. ~/.bashrc

nvm ls-remote

# Install and use v22.12.0 Node.js
VERSION=22.12.0
nvm install "$VERSION"
nvm alias default "$VERSION"
nvm use "$VERSION"

# Install npm packages
npm i -g npm@11.0.0
npm i -g \
  pm2 nodemon serve yarn corepack prettier eslint \
  npm-check-updates dotenv \
  nx nestjs @nestjs/cli nest-cli nats \
  solc solhint solidity-code-metrics \
  tronbox
corepack enable

# Check installed versions Node.js
nvm ls

echo '#################################################################'
echo "NVM & npm installed"
echo '#################################################################'
