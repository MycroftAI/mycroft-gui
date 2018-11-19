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

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

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

    PlasmaCore.Svg {
        id: clockSvg
        imagePath: "widgets/clock"
    }

    PlasmaCore.SvgItem {
        id: face
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: Math.min(parent.width, parent.height)
        svg: clockSvg
        elementId: "ClockFace"
    }

    Hand {
        anchors.topMargin: 3
        elementId: "HourHandShdow"
        rotation: 180 + _hours * 30 + (_minutes/2)
        svgScale: face.width / face.naturalSize.width

    }
    Hand {
        elementId: "HourHand"
        rotation: 180 + _hours * 30 + (_minutes/2)
        svgScale: face.width / face.naturalSize.width
    }

    Hand {
        anchors.topMargin: 3
        elementId: "MinuteHandShadow"
        rotation: 180 + _minutes * 6
        svgScale: face.width / face.naturalSize.width
    }
    Hand {
        elementId: "MinuteHand"
        rotation: 180 + _minutes * 6
        svgScale: face.width / face.naturalSize.width
    }

    Hand {
        anchors.topMargin: 3
        elementId: "SecondHandShadow"
        rotation: 180 + _seconds * 6
        visible: showSecondsHand
        svgScale: face.width / face.naturalSize.width
    }
    Hand {
        elementId: "SecondHand"
        rotation: 180 + _seconds * 6
        visible: showSecondsHand
        svgScale: face.width / face.naturalSize.width
    }

    PlasmaCore.SvgItem {
        id: center
        width: naturalSize.width * face.width / face.naturalSize.width
        height: naturalSize.height * face.width / face.naturalSize.width
        anchors.centerIn: clock
        svg: clockSvg
        elementId: "HandCenterScrew"
        z: 1000
    }

    PlasmaCore.SvgItem {
        anchors.fill: face
        svg: clockSvg
        elementId: "Glass"
        width: naturalSize.width * face.width / face.naturalSize.width
        height: naturalSize.height * face.width / face.naturalSize.width
    }
}
