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

//DEPRECATED or inherit fom c++ Delegate?
import QtQuick 2.4
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

//TODO: should all delegates be a Kirigami Page?
Mycroft.AbstractDelegate {
    id: control
    //FIXME: all of this should be grouped
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

    readonly property bool userInteracting: main ?main.pressed : false

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
            opacity: status == Image.Ready
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration * 2
                    easing.type: Easing.InOutCubic
                }
            }
        }
        Rectangle {
            id: rect
            anchors.fill: parent
            //TODO: api for having skills that just fill a solid color
            color: "black"
            opacity: 0.6
        }
    }

     MouseArea {
        id: main
        drag.filterChildren: true
    }
}
