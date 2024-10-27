#!/bin/bash

echo 'Installing Bluetooth Audio for AirPods'
echo '#################################################################'
# sudo apt install -y 'bluez*' blueman
modprobe btusb
sudo tee -a /etc/bluetooth/main.conf <<< \
'
ControllerMode = bredr
ControllerMode = dual
'
sudo /etc/init.d/bluetooth restart
sudo systemctl restart bluetooth
echo '#################################################################'
