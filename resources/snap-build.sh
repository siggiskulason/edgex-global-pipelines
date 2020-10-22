#!/bin/bash
set -ex -o pipefail

echo "snap-build.sh"

# assume building in the current directory
SNAP_BASE_DIR=.

if [ ! -z $WORKSPACE ]; then
  SNAP_BASE_DIR=$WORKSPACE
fi

# script to build the edgexfoundry snap on ubuntu
# installs lxd, snapcraft, and then builds the snap 
echo "[snap-build] Building snap in dir [$SNAP_BASE_DIR]"

cd "$SNAP_BASE_DIR"

# remove lxd
sudo apt-get remove -qy --purge lxd lxd-client
sudo snap remove --purge lxd
# set up lxd group
sudo groupadd --force --system lxd
sudo /usr/sbin/usermod -G lxd -a "$(whoami)"
newgrp - lxd
#install lxd
sudo snap install lxd
sudo lxd init --auto
# install snapcraft
sudo snap install --classic snapcraft
#patch the snapcraft.yml file
patch --verbose -p1 < snap/local/patches/0001-optimize-build-for-pipeline-CI-check.patch
# run snapcraft
snapcraft --use-lxd
