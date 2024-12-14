# Install the Intel graphics GPG public key
wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
  sudo gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg

# Configure the repositories.intel.com package repository
echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | \
  sudo tee /etc/apt/sources.list.d/intel-gpu-noble.list

# Update the package repository meta-data
sudo apt update

# Install the compute-related packages
sudo apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo
sudo apt install -y libze-dev intel-ocloc

clinfo | grep "Device Name"
sudo gpasswd -a ${USER} render
newgrp render


# lspci -nn | grep -Ei 'VGA|DISPLAY'
# # 00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-P GT2 [Iris Xe Graphics] [8086:46a6] (rev 0c)

# # Change the value to your PCI device ID
# export INTEL_GPU="8086:46a6"

# eval "$(grep ^GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub)"
# declare -i updated=0
# if [[ ! "intel_iommu=on" =~ ${GRUB_CMDLINE_LINUX_DEFAULT} ]]; then
#   echo "Adding 'intel_iommu=on'"
#   GRUB_CMDLINE_LINUX_DEFAULT+=" intel_iommu=on"
#   updated=1
# fi
# if [[ ! "vfio-pci.ids=${INTEL_GPU}" =~ ${GRUB_CMDLINE_LINUX_DEFAULT} ]]; then
#   echo "Adding 'vfio-pci.ids=${INTEL_GPU}'"
#   GRUB_CMDLINE_LINUX_DEFAULT+=" vfio-pci.ids=${INTEL_GPU}"
#   updated=1
# fi
# if ! grep -q "vfio-pci" /etc/modules; then
#    echo "vfio-pci" | sudo tee -a /etc/modules >/dev/null
#    echo "Added 'vfio-pci' to /etc/modules to ensure it loads and binds early."
# fi
# if (( updated )); then
#    sudo cp /etc/default/grub /etc/default/grub.bk
#    sudo sed -i -e "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*\$/GRUB_CMDLINE_LINUX_DEFAULT=\"${GRUB_CMDLINE_LINUX_DEFAULT}\"/" \
#       /etc/default/grub
#    if ! sudo update-grub; then
#       sudo cp /etc/default/grub /etc/default/grub.bk
#       echo "update-grub failed. /etc/default/grub restored from backup" >&2
#    else
#       if ! sudo update-initramfs -u; then
#          sudo cp /etc/default/grub /etc/default/grub.bk
#          echo "update-initramfs failed. /etc/default/grub restored from backup" >&2
#          if ! sudo update-grub; then
#             echo "Unable to update-grub to original configuration" >&2
#          fi
#       fi
#    fi
#    echo "GRUB configuration updated setting: ${GRUB_CMDLINE_LINUX_DEFAULT}"
# fi
# grep ^GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub

# lspci -nnk | grep -A 3 -Ei 'VGA|DISPLAY' | grep -E "VGA|driver"


# Change the value to your PCI device ID
# export INTEL_GPU_PCI="0000:$(lspci -nn | grep -Ei "${INTEL_GPU}" | sed -nE 's/^([^ ]+).*/\1/p')"

# if [[ ${#INTEL_GPU_PCI} == $(expr length "0000:00:00.0") ]]; then
#    echo "${INTEL_GPU_PCI}" |
#       sudo tee /sys/bus/pci/devices/${INTEL_GPU_PCI}/driver/unbind >/dev/null
#    echo "${INTEL_GPU/:/ }" |
#       sudo tee /sys/bus/pci/drivers/vfio-pci/new_id >/dev/null
# fi

# lspci -nnk | grep -A 3 -Ei 'VGA|DISPLAY' | grep -E "VGA|driver"
# sudo dmesg | grep -iE '(i915|vfio|xe)'


sudo apt install -y qemu-kvm qemu-utils \
  libvirt-daemon-system libvirt-clients \
  bridge-utils \
  virt-manager ovmf gir1.2-spiceclientgtk-3.0
sudo kvm-ok
sudo qemu-img create -f qcow2 /opt/ubuntu-disk.qcow2 50G
sudo chown $(whoami) /opt/ubuntu-disk.qcow2

sudo apt install -y \
  intel-opencl-icd intel-level-zero-gpu level-zero \
  intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
  va-driver-all vainfo

sudo update-grub

sudo shutdown -h 0
