Mycroft GUI 
===========
```diff
- NOTE:  This is pre-Alpha and likely to break at any time!
```

The KDE-based visual interface for working with [Mycroft](https://github.com/MycroftAI/mycroft-core).  For more on the Mycroft Skill side, see the [initial Mycroft Core GUI PR](https://github.com/MycroftAI/mycroft-core/pull/1899).



# Getting Started

## Foolproof Setup Instructions(tm)

1) Download and Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2) Download an ISO from [KDE Neon Developer Edition, Git Unstable](https://neon.kde.org/download).  Any build >= 2057.
3) Open VirtualBox and create a Neon installation
   TODO: More detailed installations?
4) Within the VM, open a terminal session and type:
   * ```cd ~```
   * ```sudo apt-get install git -y```
   * ```git clone https://github.com/mycroftai/mycroft-gui```
   * ```cd mycroft-gui```
   * ```bash dev_setup.sh```
5) (Optional) Customize Plasma settings for GUI debugging purposes
   * Disable screensaver
     - Click the > icon, type: Screen Locking
     - Untick "Lock screen automatically after:"
     - Click OK
6) Run and configure
   * ```mycroft-gui-app```
   * Click on the hamburger menu in the lower left
   * Select 'Settings'
   * Enter the IP address of your device.  If your device is at 192.168.2.2, enter 'ws://192.168.2.2'
   * Close

## Normal use

1) Invoke using ```mycroft-gui-app```
2) Click *Start* button in the middle of the window
     Note: Boot your device or run ```./start-mycroft.sh all && ./start-mycroft.sh enclosure``` prior to doing this.
3) Talk to your Mycroft!

After any code changes (if you are developing) or git pull, simply rerun ```bash dev_setup.sh``` to rebuild.


## QML synchronization

At this point, the paths to skill QML on the Mycroft must precisely match the path on the mycroft-gui-app host machine.  The
simplest way to achieve this is to run rsync.  This simple script can perform this synchronization, hanldling synchronization
with different devices (e.g. for a developer who does work both at home and at an office).

**sync.sh**
```bash
function is_online() {
    ping -q -w 1 -c 1 "$1" > /dev/null
    if [ $? -eq 0 ]; then
        rsync -av pi@$1:/opt/mycroft/skills/ /opt/mycroft/skills/
        echo "Synched!"
        return 0
    else
        return 1
    fi
}

# Attempt sync with office Mark 1
is_online 10.10.41.86
if [ $? -ne 0 ]; then
    # Attempt sync with house Mark 1
    is_online 192.168.2.165
fi
```

## Gotchas

* For a Mark 1, but sure to disable the firewall on the Raspberry Pi.  You can do this via ```sudo ufw disable```
* Generally, the GUI interaction is managed by an enclosure-specific skill that orchestrates things.  For example, the Mark 2 uses skill-mark-2.
* Lightweight debugging can be done from Mycroft's CLI.  You can see commands being sent to GUI clients by hitting Ctrl+G within the CLI
* Multiple GUIs can safely run against a single Mycroft Core instance.

## Debugging Tips

* Debug output can be seen by running the mycroft-enclosure directly from inside an SSH session.  On a Mark 1:
  - SSH to the Mark 1
  - ```sudo service mycroft-enclosure-client stop```
  - ```sudo su mycroft```
  - ```mycroft-enclosure-client```
  This will start the client and show Debug() messages on the console.


## Skill Testing

```bash
cd /opt/mycroft/skills
git clone -b newapi https://github.com/AIIX/skill-wikidata
cd #
cd mycroft-core
source .venv/bin/activate
cd /opt/mycroft/skills/skill-wikidata
pip install -r requirements.txt
```
