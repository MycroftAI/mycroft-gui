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

function found_exe() {
   hash "$1" 2>/dev/null
}

# Package installation
if [ ! -f .installed ] || ! md5sum -c &> /dev/null < .installed ; then
   # Update package dependencies whenever this file changes
   if found_exe apt-get ; then
      sudo apt-get install -y git-core g++ cmake extra-cmake-modules kio-dev gettext pkg-config qml-module-qtwebengine
      sudo apt-get install -y pkg-kde-tools qtbase5-dev qtdeclarative5-dev kio-dev
      sudo apt-get install -y libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev libkf5plasma-dev libkf5kio-dev libqt5webview5-dev
   else
      # TODO: Support for other package managers
      echo "You must manually install necessary packages for this platform"
   fi

   md5sum dev_setup.sh > .installed
fi


if [[ ! -d build-testing ]] ; then
   mkdir build-testing
fi
cd build-testing
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make -j4
sudo make install


# Setup the platform file
if [[ ! -f /etc/mycroft/mycroft.conf ]] ; then
   if [[ ! -d /etc/mycroft ]] ; then
      sudo mkdir /etc/mycroft
   fi

cat <<EOF | sudo tee /etc/mycroft/mycroft.conf
{
  "enclosure": {
     "platform": "mycroft_mark_2"
  }
}
EOF
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

