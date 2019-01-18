/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
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

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami 2.5 as Kirigami

import "../../../org.kde.mycroft.panel/contents/ui" as Panel

import Mycroft 1.0 as Mycroft

Item {
    id: root
    width: 480
    height: 640

//BEGIN properties
    property Item toolBox
    readonly property bool smallScreenMode: Math.min(width, height) < Kirigami.Units.gridUnit * 18
//END properties



//BEGIN slots
    Component.onCompleted: {
        Mycroft.MycroftController.start();
    }

    Timer {
        interval: 10000
        running: Mycroft.MycroftController.status != Mycroft.MycroftController.Open
        onTriggered: {
            print("Trying to connect to Mycroft");
            Mycroft.MycroftController.start();
        }
    }

//END slots

    Panel.SlidingPanel {
        id: panel
        z: 999
        width: root.width
        dragMargin: Kirigami.Units.gridUnit * 2
        dim: true
    }
    Rectangle {
        z: 998
        anchors.fill:parent
        color: "black"
        opacity: panel.position * 0.8
        visible: panel.position > 0
    }

    Mycroft.SkillView {
        id: skillView
        anchors.fill: parent
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        topPadding: panel.dragMargin
    }

    Controls.Button {
        anchors.centerIn: parent
        text: "start"
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Closed
        onClicked: Mycroft.MycroftController.start();
    }
}
