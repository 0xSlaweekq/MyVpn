#!/bin/bash

echo "Install NVM & npm"
echo '#################################################################'
# Install nvm
cd ~
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
npm i -g npm@10.5.2 pm2@latest nodemon serve \
  yarn prettier eslint solhint solidity-code-metrics \
  dotenv nx nestjs @nestjs/cli nest-cli nats solc npm-check-updates

# Check installed versions Node.js
nvm ls

echo '#################################################################'
echo "NVM & npm installed"
echo '#################################################################'
