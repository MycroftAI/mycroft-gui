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
import QtQuick.Templates 2.2 as T
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.private.volume 0.1 as PA
import Mycroft 1.0 as Mycroft

T.Slider {
    id: volSlider
    z: 100
    from: PA.PulseAudio.MinimalVolume
    to: PA.PulseAudio.MaximalVolume
    implicitWidth: Kirigami.Units.gridUnit * 4

    handle: Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: volSlider.height - volSlider.position * (volSlider.height - height) - height
        color: "orange"
        radius: height
        implicitWidth: Kirigami.Units.gridUnit * 8
        implicitHeight: Kirigami.Units.gridUnit * 4
        RowLayout {
            anchors {
                fill: parent
                margins: Kirigami.Units.gridUnit/2
            }
            Kirigami.Icon {
                source: "audio-volume-high"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignVCenter
            }
            Mycroft.AutoFitLabel {
                text: Math.round(volSlider.position * 10)
                font.bold: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
    background: Rectangle {
        color: Qt.rgba(0.2, 0.2, 0.2, 0.6)
        radius: width
        Rectangle {
            color: Kirigami.Theme.highlightColor
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            radius: width
            height: volSlider.position * (volSlider.height - width) + width
        }
    }
    value: paSinkModel.preferredSink ? paSinkModel.preferredSink.volume : PA.PulseAudio.MinimalVolume
    function show () {
        opacity = 1;
        volSliderTimer.restart();
    }
    anchors {
        top: parent.top
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        margins: Kirigami.Units.largeSpacing * 2
    }
    orientation: Qt.Vertical
    opacity: 0
    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InQuad
        }
    }
    Timer {
        id: volSliderTimer
        interval: 1000
        onTriggered: volSlider.opacity = 0
    }
}
