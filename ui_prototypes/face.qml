/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
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
import QtQuick.Layouts 1.4
import QtQuick.Shapes 1.0
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami 

Rectangle {
    id: root

    width: Kirigami.Units.gridUnit * 15
    height: Kirigami.Units.gridUnit * 24

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    property bool open: false
    color: "black"

    MouseArea {
        anchors.fill: parent
        onClicked: root.open = !root.open
    }

    Eye {
        x: parent.width/5
        y: parent.height/5
        width: parent.width/5
        height: width
        open: root.open
    }

    Eye {
        x: parent.width/5 * 3
        y: parent.height/5
        width: parent.width/5
        height: width
        open: root.open
    }

    Shape {
        id: mouthShape
        y: 0//parent.height/3
        width: parent.width/3
        height: width/2
        anchors.centerIn: parent
        ShapePath {
            strokeWidth: root.open ? mouthShape.width/10 : 1
            strokeColor: root.open ? "white" : "transparent"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            strokeStyle: ShapePath.SolidLine
            startX: 0
            startY: parent.height/8

            Behavior on strokeColor {
                ColorAnimation {
                    duration: Kirigami.Units.longDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on strokeWidth {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }

            PathCubic {
                x: mouthShape.width
                y: parent.height/8

                control1X: x/4
                control1Y: y+width/10

                control2X: x/4*3
                control2Y: y+width/10
            }
        }
    }
}
