if [ ! -d ~/mycroft-core ] ; then
   cd ~
   git clone https://github.com/mycroftai/mycroft-core.git
   cd mycroft-core
   echo "Installing, answer: N, Y, N, Y   :)"
   bash ./dev_setup.sh

   git clone https://github.com/mycroftai/skill-date-time.git mycroft-date-time.mycroftai
   cd mycroft-date-time.mycroftai
   git checkout feature/mark-2

   git clone https://github.com/mycroftai/skill-weather.git mycroft-weather.mycroftai
   cd mycroft-weather.mycroftai
   git checkout feature/mark-2

   if [ ! -d skill-mark-2 ] ; then
      git clone https://github.com/mycroftai/skill-mark-2.git
   fi
fi

if [ -s /usr/bin/mycroft-gui-core-loader ] ; then
   # Wipe out the loader, not needed when running Mycroft this way
   echo "Removing gui-core-loader"
   sudo rm /usr/bin/mycroft-gui-core-loader
   sudo touch /usr/bin/mycroft-gui-core-loader
fi

echo "Launching Mycroft Core"
cd ~/mycroft-core
./start-mycroft.sh all
./start-mycroft.sh enclosure
sleep 5

echo "Launching GUI"
mycroft-gui-app --autoconnect

