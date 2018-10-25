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
