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

import QtQuick 2.6
import org.kde.kirigami 2.4 as Kirigami

Item {
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
        z: 2
    }

    Hand {
        color: "black"
        width: face.width/2.3
        height: width/15
        rotation: 180 + _minutes * 6
        z: 2
    }

    Hand {
        color: "orange"
        width: face.width/2.2
        height: width/20
        rotation: 180 + _seconds * 6
        z: 2
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
    }
}
