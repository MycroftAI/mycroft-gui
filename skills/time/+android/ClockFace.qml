/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.6
import org.kde.kirigami 2.4 as Kirigami

Rectangle {color: "red"
    id: clock
    property date time: new Date();
    property bool showSecondsHand: false

    property int _hours: time.hours
    property int _minutes: times.minutes
    property int _seconds: time.seconds

    onTimeChanged: {
        _hours = time.getHours();
        _minutes = time.getMinutes();
        _seconds = time.getSeconds();
    }



    Rectangle {
        id: face
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: Math.min(parent.width, parent.height)
        radius: width
    }


    Hand {
        color: "black"
        width: face.width/2.8
        height: width/10
        rotation: 180 + _hours * 30 + (_minutes/2)
    }

    Hand {
        color: "black"
        width: face.width/2.3
        height: width/15
        rotation: 180 + _minutes * 6
    }

    Hand {
        color: "orange"
        width: face.width/2.2
        height: width/20
        rotation: 180 + _seconds * 6
    }

    Rectangle {
        id: center
        width: face.width/10
        radius: width
        height: width
        anchors.centerIn: clock
        color: "black"
        z: 1000
    }


    Rectangle {
        width: face.width/15
        radius: width
        height: width
        anchors {
            top: clock.top
            topMargin: width/2
            horizontalCenter: clock.horizontalCenter
        }
        color: "black"
        z: 1000
    }
    Rectangle {
        width: face.width/15
        radius: width
        height: width
        anchors {
            bottom: clock.bottom
            bottomMargin: width/2
            horizontalCenter: clock.horizontalCenter
        }
        color: "black"
        z: 1000
    }

    Rectangle {
        width: face.width/15
        radius: width
        height: width
        anchors {
            left: clock.left
            leftMargin: width/2
            verticalCenter: clock.verticalCenter
        }
        color: "black"
        z: 1000
    }
    Rectangle {
        width: face.width/15
        radius: width
        height: width
        anchors {
            right: clock.right
            rightMargin: width/2
            verticalCenter: clock.verticalCenter
        }
        color: "black"
        z: 1000
    }
}
