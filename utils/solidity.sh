#!/bin/bash

# Add Ethereum repository and install Solidity compiler
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt update
sudo apt install -y solc
solc --version

python3 -m pipx ensurepath
pipx install slither-analyzer
pipx ensurepath

# Install Slither globally (optional, with --break-system-packages)
pip3 install slither-analyzer --break-system-packages 

echo "Setup completed successfully!"
