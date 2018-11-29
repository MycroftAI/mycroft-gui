### Mycroft GUI

#### Installation

```bash
sudo apt install cmake, extra-cmake-modules, kio-dev, libkf5i18n-dev, libkf5notifications-dev, libkf5plasma-dev, libqt5websockets5-dev, libqt5webview5-dev, pkg-config, pkg-kde-tools, qtbase5-dev, qtdeclarative5-dev, qml-module-qtquick-shapes
git clone https://github.com/MycroftAI/mycroft-gui
cd mycroft-gui
mkdir build-testing
cd build-testing
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make -j4
sudo make install 
```

Setup the platform file

```bash
cd /etc
sudo mkdir mycroft
cd mycroft
sudo touch mycroft.conf
kate mycroft.conf
```

Copy the below contents in mycroft.conf

```json
{
    "enclosure": {
        "platform": "mycroft_mark_2"
    }
}
```

Installation for Lottie-Qml for animations

```bash
git clone https://github.com/kbroulik/lottie-qml
cd lottie-qml
mkdir build
cd build
cmake ..
make
sudo make install
```

#### Running

```bash
mycroft-gui-app
# Please note: run "./start-mycroft.sh all && ./start-mycroft.sh enclosure" prior to running the above 
```

#### Skill Testing

```bash
cd /opt/mycroft/skills
git clone -b newapi https://github.com/AIIX/skill-wikidata
cd #
cd mycroft-core
source .venv/bin/activate
cd /opt/mycroft/skills/skill-wikidata
pip install -r requirements.txt
```
