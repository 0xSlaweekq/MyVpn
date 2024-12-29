#!/bin/bash

# Add Ethereum repository and install Solidity compiler
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt update
sudo apt install -y python3-graphviz python3-pygraphviz solc graphviz
solc --version

python3 -m pip config set global.break-system-packages true
python3 -m pipx ensurepath
pipx ensurepath
pip install solc solc-select slither slither-analyzer eralchemy graphviz pygraphviz

echo "Setup completed successfully!"
