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

import org.kde.plasma.private.volume 0.1 as PA

import "./panel/contents/ui" as Panel

import Mycroft 1.0 as Mycroft

MouseArea {
    id: root
    width: 480
    height: 640
    drag.filterChildren: true
drag.target: skillView
//BEGIN properties
    property Item toolBox
    readonly property bool smallScreenMode: Math.min(width, height) < Kirigami.Units.gridUnit * 18
    property int startMouseY: -1
    property int startVolume: -1
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

    onPressed: {
        startVolume = paSinkModel.preferredSink.volume
        startMouseY = mouse.y
    }
    onPositionChanged: {
        var delta = startMouseY - mouse.y;
        if (Math.abs(delta) > Kirigami.Units.gridUnit) {
            root.preventStealing = true
        }
        if (root.preventStealing) {
            //mouse.accepted = true;
            print(delta)
            paSinkModel.preferredSink.volume = Math.max(PA.PulseAudio.MinimalVolume, Math.min(PA.PulseAudio.MaximalVolume, startVolume + (delta/height)*(PA.PulseAudio.MaximalVolume - PA.PulseAudio.MinimalVolume)))
            feedbackTimer.running = true;
            volSlider.show();
        }
    }
    onReleased: root.preventStealing = false;
    onCanceled: root.preventStealing = false;
//END slots

//BEGIN PulseAudio
    PA.SinkModel {
        id: paSinkModel
    }
    PA.VolumeFeedback {
        id: feedback
    }
    Timer {
        id: feedbackTimer
        interval: 250
        onTriggered: feedback.play(paSinkModel.preferredSink.index);
    }
    VolumeFeedbackGraphics {
        id: volSlider
    }
//END PulseAudio

//BEGIN VirtualKeyboard
    VirtualKeyboardLoader {
        id: virtualKeyboard
        z: 1000
    }
//END VirtualKeyboard

    Image {
        source: "background.png"
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        opacity: !skillView.currentItem
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            }
        }
    }

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

        bottomPadding: virtualKeyboard.state == "visible" ? virtualKeyboard.height : 0
    }

    Controls.Button {
        anchors.centerIn: parent
        text: "start"
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Closed
        onClicked: Mycroft.MycroftController.start();
    }
}
