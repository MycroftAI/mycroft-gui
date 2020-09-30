/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
 * Copyright 2018 David Edmundson <davidedmundson@kde.org>
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
import QtQuick.Controls 2.11
import Mycroft 1.0 as Mycroft

/* Class used to simulate the homescreen in cases where we're not using minimal shell
 */

Item {
    //I was asked to have a button. I have no idea why one wouldn't just connect on startup...
    Button {
        anchors.centerIn: parent
        text: "start"
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Closed
        onClicked: Mycroft.MycroftController.start();
    }

    ClockFace {
        id: face
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.7
        height: Math.min(parent.width, parent.height) * 0.7
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Open
        showSecondsHand: true
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: face.time = new Date();
        }
    }
}
