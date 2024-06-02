#!/bin/bash
set -e

export CONFIG_MODULE_SIG=n
export CONFIG_MODULE_SIG_ALL=n
# For current kernel
export KERNELRELEASE=$(cat /proc/version | awk '{print $3}')

temp_dir=$(mktemp -d)
echo "Installing FacetimeHD camera for $KERNELRELEASE"
cd $temp_dir
git clone https://github.com/patjak/facetimehd-firmware.git
git clone https://github.com/patjak/bcwc_pcie.git

cd $temp_dir/facetimehd-firmware
pwd
make
make install
cd $temp_dir/bcwc_pcie
pwd
make
make install
rm -rf $temp_dir

if [ ! -d "/etc/modules-load.d" ]; then
  mkdir -p "/etc/modules-load.d"
fi

cat > "/etc/modules-load.d/facetimehd.conf" << EOL
videobuf2-core
videobuf2_v4l2
videobuf2-dma-sg
facetimehd
EOL


# Workaround for depmod being skipped above with error:
# Warning: modules_install: missing 'System.map' file. Skipping depmod
echo "Generate modules.dep and map files"
sudo depmod

echo "Adding kernel modules"
# sudo modprobe -r bdc_pci
sudo modprobe facetimehd

echo "Install complete"
