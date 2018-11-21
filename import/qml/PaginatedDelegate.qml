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

//DEPRECATED if we want to manage swiping only as separate QML files
import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami

Delegate {
    id: root
    property int switchWidth: Kirigami.Units.gridUnit * 35
    property int switchHeight: Kirigami.Units.gridUnit * 35
    readonly property Kirigami.Page primaryPage: pages ? pages[0] : null

    property alias currentIndex: secondary.currentIndex
    property alias currentItem: secondary.currentItem
    property alias count: secondary.count

    default property list<Kirigami.Page> pages

    leftPadding: (typeof view  !== "undefined" && view() ? view().leftPadding : 0)
    topPadding: (typeof view  !== "undefined" && view() ? view().topPadding : 0)
    rightPadding: (typeof view  !== "undefined" && view() ? view().rightPadding : 0)
    bottomPadding: (typeof view  !== "undefined" && view() ? view().bottomPadding : 0)

    onPagesChanged: {
        if (layout.singleItem) {
            secondary.insertItem(0, primaryPageInsideHolder);
        }
        primaryPage.anchors.fill = Qt.binding(function() {return primaryPage.parent;})
        for (var i = 1; i < pages.length; ++i) {
            secondary.addItem(pages[i]);
        }
        secondary.currentIndex = 0;
    }

    //This is because this is going to have a null parent for a while, leading to the creation of a ShaderEffectSource on it which will break its input,
    //with a container outside the page, we can reparent the page before removing the container
    Item {
        id: primaryPageInsideHolder
        visible: layout.singleItem
        readonly property Flickable flickable: primaryPage.flickable
    }
    GridLayout {
        id: layout
        anchors.fill: parent

        property bool singleItem: columns < 2 && height <= switchHeight
        columns: width > switchWidth ? 2 : 1

        onSingleItemChanged: {
            if (singleItem) {
                if (primaryPage.hasOwnProperty("layer")) {
                    primaryPageInsideHolder.layer.enabled = false //DAVE This is a hack round something..but I don't know what
                }
                primaryPage.parent = primaryPageInsideHolder;
                secondary.insertItem(0, primaryPageInsideHolder);
                primaryPageInsideHolder.visible = true;
                primaryPageInsideHolder.opacity = 1;
            } else {
                console.log(primaryPage.color);
                if (secondary.itemAt(0) != primaryPageInsideHolder) {
                    console.error("ERROR: the first item is not primaryPage: this should never happen")
                    return;
                }
                primaryPageInsideHolder.visible = false
                secondary.takeItem(0);
                primaryPage.parent = primaryPageOutsideHolder;
            }
            secondary.currentIndex = 0;
        }

        Item {
            id: primaryPageOutsideHolder
            z: secondary.z + 1
            visible: !layout.singleItem
            Layout.fillWidth: true
            Layout.fillHeight: true //fill width to evenly split layout
        }
        Controls.SwipeView {
            id: secondary
            clip: true
            currentIndex: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    LinearGradient {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.controlBarItem.height
        visible: root.controlBarItem.visible
        start: Qt.point(0, 0)
        end: Qt.point(0, height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    controlBar: Item {
        height: childrenRect.height
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: Kirigami.Units.largeSpacing
        }

        Controls.RoundButton {
            icon.name: "go-previous-symbolic"
            anchors {
                left: parent.left
            }
            onClicked: {
                if (secondary.currentIndex > 0) {
                    secondary.currentIndex--;
                } else {
                    root.backRequested();
                }
            }
        }

        Controls.PageIndicator {
            visible: secondary.contentChildren.length > 1
            anchors.verticalCenter: parent.verticalCenter
            x: secondary.x + secondary.width/2 - width/2
            count: secondary.count
            currentIndex: secondary.currentIndex
        }

        Controls.RoundButton {
            visible: secondary.contentChildren.length > 1
            anchors.right: parent.right
            icon.name: "go-next-symbolic"
            enabled: secondary.currentIndex < secondary.count - 1
            onClicked: secondary.currentIndex++
        }
    }
}
