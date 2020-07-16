#!/usr/bin/env bash

# Utility to synchronize skills from a remote instance of Mycroft to
# this local instance of the mycroft-gui.  This allows the QML files
# and resources to be specified using "file://..." URLs, which must
# be exactly the same for both machines.

remote_username=pi

function sync_from() {
    ping -q -w 1 -c 1 "$1" > /dev/null
    if [ $? -eq 0 ]; then
        rsync -r -I -q --delete --delete-after ${remote_username}@$1:/opt/mycroft/skills/ /opt/mycroft/skills/
        if [ $? -eq 0 ]; then
            echo "Skills synched! ($1)"
        else
            echo "Error synching"
        fi
        return 0
    else
        echo "Unable to sync, machine at $1 not online."
        return 1
    fi
}

# Read the IP from the mycroft-gui-app
FILE=~/.config/Unknown\ Organization/mycroft-gui-app.conf
if test -f "$FILE"; then
    ip=$( sed -nr "/^\[General\]/ { :l /^webSocketAddress[ ]*=/ { s/.*=[ ]*ws:\/\///; p; q;}; n; b l;}" $FILE )
    sync_from $ip
fi