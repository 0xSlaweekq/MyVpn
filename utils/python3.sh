#!/bin/bash

echo '#### Installing Python3'
echo '#################################################################'
if [[ $(which --version) && $(python3 --version) && $(pip3 --version) ]]; then
   echo 'Python3 installed, continue...'
else
   echo 'Python3 NOT installed, continue...'
sudo apt update
sudo apt upgrade -y
sudo apt install --fix-broken -y
sudo apt autoremove --purge -y
sudo apt autoclean -y
sudo apt clean -y

sudo apt install -y \
  cpu-checker python3-pip python3-dev python3-virtualenv \
  python3-venv python-is-python3 python3 python3-full build-essential \
  software-properties-common wget zlib1g-dev libffi-dev libgdbm-dev \
  libnss3-dev libssl-dev libreadline-dev

modprobe kvm
modprobe kvm_intel
kvm-ok
lsmod | grep kvm
ls -al /dev/kvm
sudo usermod -aG kvm msi

cd /tmp
wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz
tar -xf Python-3.11.0.tgz
cd Python-3.11.0
./configure --enable-optimizations
sudo make install
cd ~

source ~/.bashrc
python3 --version
pip3 --version
pip3 install slither-analyzer pipenv
pip3 install --upgrade pip
echo '#### Python3 installed'
echo '#################################################################'
fi


# git clone https://github.com/crytic/slither
# cd slither
# git checkout dev
# make dev
# source ./env/bin/activate

# python3 -m pip install solc-select
# solc-select install 0.8.25
# solc-select use 0.8.25
