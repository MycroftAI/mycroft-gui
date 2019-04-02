/*
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

import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Item {
    id: networkPasswordScreen
    anchors.fill: parent
    
    PlasmaNM.Handler {
        id: handler
    }
    
    Item {
        id: topArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Kirigami.Units.largeSpacing * 1.5
        height: Kirigami.Units.gridUnit * 2
        
        Kirigami.Heading {
            id: connectionTextHeading
            level: 1
            wrapMode: Text.WordWrap
            width: parent.width
            anchors.centerIn: parent
            font.bold: true
            text: "Enter Password For " + connectionName
            color: Kirigami.Theme.linkColor
        }
    }
    
    Item {
        anchors.top: topArea.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: areaSep.top
        
        PlasmaComponents.TextField {
            id: passField
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.largeSpacing
            width: parent.width
            height: Kirigami.Units.gridUnit * 3
            property int securityType
            echoMode: TextInput.Password
            revealPasswordButtonShown: true
            placeholderText: i18n("Password...")
            validator: RegExpValidator {
                            regExp: if (securityType == PlasmaNM.Enums.StaticWep) {
                                        /^(?:.{5}|[0-9a-fA-F]{10}|.{13}|[0-9a-fA-F]{26}){1}$/
                                    } else {
                                        /^(?:.{8,64}){1}$/
                                    }
                            }
                            
            onAccepted: {
                 networkingLoader.source = "../networking/Connecting.qml"
                 handler.addAndActivateConnection(devicePath, specificPath, passField.text)
            }
        }
    
        Button {
            anchors.top: passField.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 3
            text: "Connect"
        
            onClicked: {
                    networkingLoader.source = "../networking/Connecting.qml"
                    handler.addAndActivateConnection(devicePath, specificPath, passField.text)
            }
        }
    }
    
    Kirigami.Separator {
        id: areaSep
        anchors.bottom: bottomArea.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
    }
    
    Item {
        id: bottomArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing * 1.15
        height: backIcon.implicitHeight + Kirigami.Units.largeSpacing * 1.15
                
        RowLayout {
            anchors.fill: parent
            
            Kirigami.Icon {
                id: backIcon
                source: "go-previous"
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            }
            
            Kirigami.Heading {
                level: 2
                wrapMode: Text.WordWrap
                font.bold: true
                text: "Select Wi-Fi Network"
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                networkingLoader.source = "../networking/SelectNetwork.qml"
            }
        }
    }
}
