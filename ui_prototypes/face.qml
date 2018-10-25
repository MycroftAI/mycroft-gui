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
