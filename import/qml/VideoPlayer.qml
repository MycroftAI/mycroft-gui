/*
 * Copyright 2019 by Aditya Mehra <aix.m@outlook.com>
 * Copyright 2019 by Marco Martin <mart@kde.org>
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
import QtQuick.Controls 2.2 as Controls
import QtQuick.Templates 2.2 as Templates
import QtQuick.Layouts 1.3
import QtMultimedia 5.9
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

Item {
    id: root

    property alias source: video.source
    property string status: "stop"
    property bool progressBar: true
    property bool hasNextAction: true
    property bool hasPreviousAction: true
    property bool controlBarOpened: false
    property var nextAction
    property var previousAction
    property alias currentState: video.status
    
    onEnabledChanged: syncStatusTimer.restart()
    onSourceChanged: syncStatusTimer.restart()
    Component.onCompleted: syncStatusTimer.restart()
    
    function formatTime(timeInMs) {
        if (!timeInMs || timeInMs <= 0) return "0:00"
        var seconds = timeInMs / 1000;
        var minutes = Math.floor(seconds / 60)
        seconds = Math.floor(seconds % 60)
        if (seconds < 10) seconds = "0" + seconds;
        return minutes + ":" + seconds
    }
    
    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.controlBarOpened = false;
    }

    // Sometimes can't be restarted reliably immediately, put it in a timer
    Timer {
        id: syncStatusTimer
        interval: 0
        onTriggered: {
            if (enabled && status == "play") {
                video.play();
            } else if (status == "stop") {
                video.stop();
            } else {
                video.pause();
            }
        }
    }
    
    Video {
        id: video
        anchors.fill: parent
        focus: true
        autoLoad: true
        autoPlay: false
        readonly property string currentStatus: root.enabled ? root.status : "pause"
        Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
        Keys.onLeftPressed: video.seek(video.position - 5000)
        Keys.onRightPressed: video.seek(video.position + 5000)
        
        onSourceChanged: {
            console.log(source)
        }

        onCurrentStatusChanged: {
            switch(currentStatus){
            case "stop":
                video.stop();
                break;
            case "pause":
                video.pause()
                break;
            case "play":
                video.play()
                break;
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: controlBarOpened = !controlBarOpened
        }
    }

    
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        implicitHeight: controlLayout.implicitHeight + Kirigami.Units.largeSpacing * 2
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.6)
        opacity: controlBarOpened
        
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }

        onOpacityChanged: {
            if (controlBarOpened) {
                hideTimer.restart();
            }
        }
        
        RowLayout {
            id: controlLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            
            Controls.RoundButton {
                id: backButton
                Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.minimumHeight: width
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 3
                Layout.maximumHeight: width
                icon.name: "go-previous-symbolic"
                z: 1000
                onClicked: {
                    Mycroft.MycroftController.sendRequest("mycroft.gui.screen.close", {});
                    video.stop();
                }
            }

            Controls.RoundButton {
                id: previousButton
                Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.minimumHeight: width
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 3
                Layout.maximumHeight: width
                focus: false
                icon.name: "media-seek-backward"
                visible: hasNextAction
                onClicked: {
                    triggerGuiEvent(previousAction, {})
                    previousButton.focus = false
                }
            }

            Controls.RoundButton {
                id: playButton
                Layout.minimumWidth: Kirigami.Units.iconSizes.medium
                Layout.minimumHeight: width
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 4
                Layout.maximumHeight: width
                focus: false
                icon.name: video.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                onClicked: {
                    video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play()
                    playButton.focus = false
                }
            }

            Controls.RoundButton {
                id: nextButton
                Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.minimumHeight: width
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 3
                Layout.maximumHeight: width
                focus: false
                icon.name: "media-seek-forward"
                visible: hasPreviousAction
                onClicked: {
                    triggerGuiEvent(nextAction, {})
                    nextButton.focus = false
                }
            }

            Templates.Slider {
                id: slider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                implicitHeight: Kirigami.Units.gridUnit
                value: video.position
                from: 0
                to: video.duration
                z: 1000
                onMoved: {
                    video.seek(value);
                    hideTimer.restart();
                }
                handle: Rectangle {
                    x: slider.position * (parent.width - width)
                    implicitWidth: Kirigami.Units.gridUnit
                    implicitHeight: implicitWidth
                    radius: width
                }
                background: Item {
                    Rectangle {
                        id: groove
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                        }
                        radius: height
                        height: Math.round(Kirigami.Units.gridUnit/3)
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.3)
                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            radius: height
                            color: Kirigami.Theme.highlightColor
                            width: slider.position * (parent.width - slider.handle.width/2) + slider.handle.width/2
                        }
                    }

                    Controls.Label {
                        anchors {
                            left: parent.left
                            top: groove.bottom
                            topMargin: Kirigami.Units.smallSpacing
                        }
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: formatTime(playPosition)
                        color: "white"
                    }

                    Controls.Label {
                        anchors {
                            right: parent.right
                            top: groove.bottom
                            topMargin: Kirigami.Units.smallSpacing
                        }
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        text: formatTime(duration)
                    }
                }
            }
        }
    }
}

