/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

ItemBase {
    id: root

    Component.onCompleted: fetchDashWeather()

    Timer {
        running: true
        repeat: true
        //update weather every 5 minutes
        interval: 5*60*1000
        onTriggered: fetchDashWeather();
    }
    function fetchDashWeather() {
        Mycroft.MycroftController.sendRequest("mycroftai.mycroft-weather.weather_dashboard", {});
    }

    Mycroft.SkillLoader {
        id: skillLoader
    }

    Connections {
        id: mycroftConnection
        target: Mycroft.MycroftController
        onStatusChanged: {
            if (Mycroft.MycroftController.status == Mycroft.MycroftController.Open) {
                fetchDashWeather();
            }
        }
        onSkillDataRecieved: {
            if (data["type"] !== "mycroft-weather/dashboard") {
                return;
            }

            var _url = skillLoader.uiForMetadataType("mycroft-weather");
            if (!_url) {
                return;
            }
            //HACK TODO: dashboard from skillLoader
            _url = _url.replace("Main", "Dashboard");
            if (loader.item) {
                for (key in data) {
                    if (loader.item.hasOwnProperty(key)) {
                        loader.item[key] = data[key];
                    }
                }
            } else {
                loader.setSource(_url, data);
            }
        }
    }
    Loader {
        id: loader
        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }
    }
}

