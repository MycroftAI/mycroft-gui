#!/usr/bin/env bash

# exit on any error
set -Ee

# Enter the directory that contains this script file
cd $(dirname $0)
TOP=$( pwd -L )

if [ $(id -u) -eq 0 ] ; then
    echo "This script should not be run as root or with sudo."
    return 1
fi


# Installation
if [[ ! -d build-testing ]] ; then
   mkdir build-testing
fi
cd build-testing
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make -j4
sudo make install


# Setup the platform file
if [[ ! -f /etc/mycroft/mycroft.conf ]] ; then
   if [[ ! -d mycroft ]] ; then
      sudo mkdir /etc/mycroft
   fi
   sudo echo "{" > /etc/mycroft/mycroft.conf
   sudo echo '  "enclosure": { ' >> /etc/mycroft/mycroft.conf
   sudo echo '     "platform": "mycroft_mark_2"' >> /etc/mycroft/mycroft.conf
   sudo echo ' }' >> /etc/mycroft/mycroft.conf
fi


# Install / update Lottie-Qml for animations
cd $TOP
if [[ ! -d lottie-qml ]] ; then
   git clone https://github.com/kbroulik/lottie-qml
   cd lottie-qml
   mkdir build
else
   cd lottie-qml
   git pull
fi

cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
sudo make install



echo "Installation complete!"
echo "To run, invoke:  mycroft-gui-app"

