/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
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

import QtQuick 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.milou 0.1 as Milou

Rectangle {
    id: editOverlay
    anchors.fill: parent

    property Item applet
    color: Qt.rgba(0, 0, 0, 0.8)
    visible: false
    onVisibleChanged: {
        if (visible) {
            opacity = 1;
        }
    }
    opacity: 0
    Behavior on opacity {
        SequentialAnimation {
            OpacityAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: {
                    if (editOverlay.opacity == 0) {
                        editOverlay.visible = false;
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        onClicked: editOverlay.opacity = 0;
        PlasmaComponents.ButtonRow {
            visible: editOverlay.applet
            spacing: 0
            exclusive: false
            anchors.horizontalCenter: parent.horizontalCenter
            y: editOverlay.applet ? editOverlay.mapFromItem(editOverlay.applet.parent, 0, editOverlay.applet.y).y + editOverlay.applet.height/2 - height/2 : 0
            PlasmaComponents.ToolButton {
                iconSource: "configure"
                text: i18n("Configure...")
                flat: false
                onClicked: {
                    editOverlay.applet.applet.action("configure").trigger();
                    editOverlay.opacity = 0;
                }
            }
            PlasmaComponents.ToolButton {
                iconSource: "window-close"
                text: i18n("Remove")
                flat: false
                onClicked: {
                    editOverlay.applet.applet.action("remove").trigger();
                    editOverlay.opacity = 0;
                }
            }
        }
    }
    PlasmaCore.FrameSvgItem {
        id: background
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: editOverlay.height - (plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height)
        }
        height: buttonsLayout.height + fixedMargins.top + fixedMargins.bottom/2
        imagePath: "widgets/background"
        enabledBorders: PlasmaCore.FrameSvg.TopBorder
        RowLayout {
            id: buttonsLayout
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: parent.fixedMargins.top
                leftMargin: parent.fixedMargins.left/2
                rightMargin: parent.fixedMargins.right/2
                bottomMargin: parent.fixedMargins.bottom/2
            }
            PlasmaComponents.ToolButton {
                Layout.fillWidth: true
                Layout.fillHeight:true
                text: i18n("Wallpaper...")
                onClicked: {
                    plasmoid.action("configure").trigger();
                    editOverlay.opacity = 0;
                }
            }
            PlasmaComponents.ToolButton {
                Layout.fillWidth: true
                Layout.fillHeight:true
                text: i18n("Add Widgets...")
                onClicked: {
                    plasmoid.action("add widgets").trigger();
                    editOverlay.opacity = 0;
                }
            }
        }
    }
}

