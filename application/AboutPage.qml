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
    title: "About"
    objectName: "About"

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.Titles
    Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.Window

    ColumnLayout {
        id: aboutLayout
        width: parent.width
        implicitHeight: childrenRect.height
        spacing: Kirigami.Units.largeSpacing
        
        Kirigami.Heading {
            id: clientLabel
            level: 2
            font.bold: true
            color: Kirigami.Theme.textColor;
            Layout.fillWidth: true
            text: "Client Information"
        }
        
        Controls.Label {
            id: andappverlabel
            visible: Kirigami.Settings.isMobile
            text: !isAndroid && Kirigami.Settings.isMobile ? "Application Version: " + versionNumber : "Android Application Version: " + versionNumber
            Layout.fillWidth: true
        }
        
        Controls.Label {
            id: mycroftguiapplabel
            visible: !Kirigami.Settings.isMobile
            text: "Mycroft GUI Version: " + versionNumber
            Layout.fillWidth: true
        }
        
        Item {
            Layout.minimumHeight: Kirigami.Units.largeSpacing * 2
        }
        
        Kirigami.Heading {
            id: licenselabel
            level: 2
            font.bold: true
            color: Kirigami.Theme.textColor;
            Layout.fillWidth: true
            text: "License"
        }
        
        Controls.Label {
            id: licenseinfolabel
            text: "Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 <br><br> Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License."
            Layout.fillWidth: true
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
        }
    }
} 
