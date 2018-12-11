/*
 * Copyright 2018 Marco Martin <mart@kde.org>
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Kirigami.ScrollablePage {
    title: "Settings"
    objectName: "Settings"
    

    ColumnLayout {
        id: settingsLayout
        anchors.fill: parent
        Layout.fillWidth: true
        width: parent.width
        
        Controls.Label {
            id: websocketLabel 
            text: "<h1>Websocket Address</h1> Example: <tt>ws://192.168.1.1</tt>"
        }
        
        Controls.TextField {
            id: webSocketAddressField
            width: parent.width
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Component.onCompleted:{
                webSocketAddressField.text = Mycroft.GlobalSettings.webSocketAddress
            }
        }

        Controls.Button{
            id: applySettings
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            text: "Apply"
            
            onClicked:{ 
                Mycroft.GlobalSettings.webSocketAddress = webSocketAddressField.text
                Mycroft.MycroftController.reconnect()
            }
        }
    }
}
