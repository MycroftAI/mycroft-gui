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

import QtQuick 2.4
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami

//TODO: should all delegates be a Kirigami Page?
Controls.Control {
    id: control
    property int graceTime: 6000
    //FIXME: all of this should be grouped
    property alias backgroundImage: img.source
    property alias backgroundHorizontalAlignment: img.horizontalAlignment
    property alias backgroundVerticalAlignment: img.verticalAlignment
    property alias backgroundDim: rect.opacity


    signal backRequested

    property Component controlBar: Controls.RoundButton {
        z: 99999
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: control.leftPadding
            bottomMargin: control.bottomPadding
        }
        icon.name: "go-previous-symbolic"
        onClicked: control.backRequested();
    }

    readonly property Item controlBarItem: controlBar.createObject(control);

    readonly property bool userInteracting: main.pressed

    //To do some automatic responsive layouting
    readonly property bool wideMode: width > Kirigami.Units.gridUnit * 18

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    leftPadding: (typeof view  !== "undefined" && view() ?view().leftPadding : 0) + Kirigami.Units.largeSpacing
    topPadding: (typeof view  !== "undefined" && view() ?view().topPadding : 0) + Kirigami.Units.largeSpacing
    rightPadding: (typeof view  !== "undefined" && view() ?view().rightPadding : 0) + Kirigami.Units.largeSpacing
    bottomPadding: (typeof view  !== "undefined" && view() ?view().bottomPadding : 0) + Kirigami.Units.largeSpacing

    //this to make all items children of contentItem so everything will have paddings automagically
    default property alias data: main.data
    //TODO: make this background an internal component
    //so the implementation can do background.image: "foo" background.dim: 0.6 etc as grouped properties
    background: Item {
        Image {
            id: img
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            id: rect
            anchors.fill: parent
            //TODO: api for having skills that just fill a solid color
            color: "black"
            opacity: 0.6
        }
    }

    contentItem: MouseArea {
        id: main
        drag.filterChildren: true
    }
}
