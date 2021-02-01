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
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

Kirigami.ScrollablePage {
    title: "Settings"
    objectName: "Settings"

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.Titles

    ColumnLayout {
        id: settingsLayout
        width: parent.width
        implicitHeight: childrenRect.height
        spacing: Kirigami.Units.largeSpacing
        
        Kirigami.Heading {
            id: websocketLabel
            level: 2
            font.bold: true
            color: Kirigami.Theme.textColor;
            Layout.fillWidth: true
            text: "Mycroft Core Address"
        }
        
        Controls.Label {
            id: exampleLabel
            text: "Example: <tt>ws://192.168.1.1</tt>"
            Layout.fillWidth: true
        }
                
        Controls.Control{ 
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3
            leftPadding: Kirigami.Units.largeSpacing
            rightPadding: Kirigami.Units.largeSpacing
            
            background: Rectangle {
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                color: Kirigami.Theme.backgroundColor
                radius: 5
            }
            
            contentItem: Controls.TextField {
                id: webSocketAddressField
                
                Component.onCompleted:{
                    webSocketAddressField.text = Mycroft.GlobalSettings.webSocketAddress
                }
            }
        }

        RowLayout {
           Layout.fillWidth: true
           Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                       
           Controls.Button {
                id: applySettings
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                text: "Apply"
                
                onClicked:{ 
                    Mycroft.GlobalSettings.webSocketAddress = webSocketAddressField.text
                    Mycroft.MycroftController.reconnect()
                }
            }
           
           Controls.Button{
                id: reverSettings
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                text: "Revert"
                
                onClicked: {
                    webSocketAddressField.text = "ws://0.0.0.0"
                    Mycroft.GlobalSettings.webSocketAddress = webSocketAddressField.text
                    Mycroft.MycroftController.reconnect()
                }
            }
        }
        
        Item {
            Layout.preferredHeight: Kirigami.Units.largeSpacing * 2
        }
        
        Controls.Switch {
            text: "Connect Automatically"
            checked: Mycroft.GlobalSettings.autoConnect
            onCheckedChanged: Mycroft.GlobalSettings.autoConnect = checked
        }
        
        Controls.Switch {
            id: remoteSTTSwitch
            text: "Remote STT"
            checked: applicationSettings.usesRemoteSTT
            onCheckedChanged: applicationSettings.usesRemoteSTT = checked
            visible: Mycroft.GlobalSettings.displayRemoteConfig
        }
        
        Controls.Switch {
            text: "Remote TTS"
            checked: Mycroft.GlobalSettings.usesRemoteTTS
            onCheckedChanged: Mycroft.GlobalSettings.usesRemoteTTS = checked
            visible: Mycroft.GlobalSettings.displayRemoteConfig
        }
    }
}
