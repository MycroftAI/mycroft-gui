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

Item {
    id: root

    width: Kirigami.Units.gridUnit * 3
    height: width

    property bool open: true

    Shape {
        id: eyeShape
        width: parent.width
        height: width
        anchors.centerIn: parent
        ShapePath {
            strokeWidth: eyeShape.width/10
            strokeColor: Kirigami.Theme.textColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            strokeStyle: ShapePath.SolidLine
            startX: 0
            startY: 0

            PathCubic {
                x: eyeShape.width
                y: 0

                control1X: 0
                control1Y: eyeShape.height/3*2

                control2X: x
                control2Y: eyeShape.height/3*2
            }
        }
    }

    Shape {
        id: lidShape
        width: parent.width
        height: width
        anchors.centerIn: parent
        state: root.open ? "open" : "closed"
        ShapePath {
            strokeWidth: lidShape.width/10
            strokeColor: "white"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            strokeStyle: ShapePath.SolidLine
            startX: 0
            startY: 0

            PathCubic {
                id: lidPath
                x: lidShape.width
                y: 0

                control1X: 0

                control2X: x
            }
        }
        states: [
            State {
                name: "open"
                PropertyChanges {
                    target: lidPath
                    control1Y: -lidShape.height/3*2
                    control2Y: -lidShape.height/3*2
                }
            },
            State {
                name: "closed"
                PropertyChanges {
                    target: lidPath
                    control1Y: lidShape.height/3*2
                    control2Y: lidShape.height/3*2
                }
            }
        ]
        transitions: [
            Transition {
                NumberAnimation {
                    properties: "control1Y,control2Y"
                    duration: Kirigami.Units.longDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
        ]
    }
}
