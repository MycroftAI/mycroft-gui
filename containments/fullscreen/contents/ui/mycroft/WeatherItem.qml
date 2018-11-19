/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
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

