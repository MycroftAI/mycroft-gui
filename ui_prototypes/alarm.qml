/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami 

Rectangle {
    id: root

    width: Kirigami.Units.gridUnit * 15
    height: Kirigami.Units.gridUnit * 24

    color: "black"
    state: "idle"

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    property int hours: 6
    property string time: "6:59"

    Timer {
        id: ringTimer
        interval: 3000
        running: true
        onTriggered: {
            time = "7:00"
            root.state = "ringing"
        }
    }
    Rectangle {
        id: mainRect
        anchors.fill: parent
        radius: Kirigami.Units.gridUnit
        color: Kirigami.Theme.backgroundColor

        Behavior on color {
            ColorAnimation {
                duration: Kirigami.Units.longDuration*3
                easing.type: Easing.InOutCubic
            }
        }

        Rectangle {
            id: alarmRectangle
            anchors.centerIn: parent
            opacity: 0
            scale: 0
            width: Math.min(parent.width, parent.height) * 1.5
            height: width
            radius: root.width
            color: "gold"
            Behavior on scale {
                SpringAnimation {
                    velocity: 20
                    spring: 5
                    mass: 1
                    damping: 0.08
                }
            }
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
            }
        }

        ColumnLayout {
            id: timeLayout
            x: parent.width/2 - width/2
            y: x
            spacing: 0
            Kirigami.Heading {//HACK ON SIZE
                font.pointSize: 50
                text: time
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Controls.Label {
                    font.pointSize: 20
                    Layout.preferredHeight: paintedHeight
                    verticalAlignment: Text.AlignTop
                    text: "AM"
                    color: root.state == "ringing" ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor
                    Behavior on color {
                        ColorAnimation {
                            duration: Kirigami.Units.longDuration*3
                            easing.type: Easing.InOutCubic
                        }
                    }
                }
            }
            Behavior on y {
                SpringAnimation {
                    velocity: 3000
                    spring: 5
                    mass: 1
                    damping: 0.08
                }
            }
        }

        Kirigami.Icon {
            id: alarmIcon
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: x
            }
            smooth: true
            width: Kirigami.Units.iconSizes.huge
            height: width
            source: "alarm-symbolic"
            Behavior on scale {
                SpringAnimation {
                    velocity: 20
                    spring: 5
                    mass: 1
                    damping: 0.08
                }
            }
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.state = "idle"
            ringTimer.restart();
        }
    }

    states: [
        State {
            name: "idle"
            PropertyChanges {
                target: mainRect
                color: "black"
            }
            PropertyChanges {
                target: timeLayout
                y: mainRect.height/2 - timeLayout.height/2
            }
            PropertyChanges {
                target: alarmIcon
                scale: 0.4
                opacity: 0.5
            }
            PropertyChanges {
                target: alarmRectangle
                scale: 0
                opacity: 0
            }
        },
        State {
            name: "ringing"
            PropertyChanges {
                target: mainRect
                color: "#fffadb"
            }
            PropertyChanges {
                target: alarmRectangle
                scale: 1
                opacity: 1
            }
            PropertyChanges {
                target: alarmIcon
                scale: 1
                opacity: 1
            }
            PropertyChanges {
                target: timeLayout
                y: timeLayout.x
            }
        }
    ]
}
