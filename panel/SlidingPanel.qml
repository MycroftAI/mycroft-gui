/*
 *   Copyright 2018 Marco Martin <notmart@gmail.com>
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
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.5 as Kirigami
import "quicksettings"

Controls.Drawer {
    id: root
    edge: Qt.TopEdge
    width: window.width

    property bool peeking: false

    property Item bottomItem

    onBottomItemChanged: {
        bottomItem.parent = contentArea;
        bottomItem.anchors.fill = contentArea;
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    contentItem: PlasmaCore.ColorScope {
        Kirigami.Theme.colorSet: root.Kirigami.Theme.colorSet
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        implicitWidth: layout.implicitWidth + Kirigami.Units.largeSpacing * 2
        implicitHeight: layout.implicitHeight + Kirigami.Units.largeSpacing * 2
        ColumnLayout {
            id: layout
            anchors {
                fill: parent
                margins: Kirigami.Units.largeSpacing
            }

            //height: 300
            QuickSettings {
                Layout.fillWidth: true
                drawer: root
            }
            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.preferredHeight: root.bottomItem ? root.bottomItem.implicitHeight : 0
            }
        }
    }
    background: Rectangle {
        anchors.fill: parent
        Kirigami.Theme.colorSet: root.Kirigami.Theme.colorSet
        color: Kirigami.Theme.backgroundColor
        Kirigami.Separator {
            color: Kirigami.Theme.highlightColor
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
        Rectangle {
            height: units.smallSpacing
            anchors {
                left: parent.left
                right: parent.right
                top: parent.bottom
            }
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.6)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(0, 0, 0, 0.2)
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }
    }

    onPeekingChanged:  {
        if (peeking) {
            root.enter.enabled = false;
            root.exit.enabled = false;
            visible = true;
        } else {
            positionResetAnim.to = position > 0.5 ? 1 : 0;
            positionResetAnim.running = true
            root.enter.enabled = true;
            root.exit.enabled = true;
        }
    }
    SequentialAnimation {
        id: positionResetAnim
        property alias to: internalAnim.to
        NumberAnimation {
            id: internalAnim
            target: root
            to: 0
            property: "position"
            duration: (root.position)*Kirigami.Units.longDuration
        }
        ScriptAction {
            script: {
                if (internalAnim.to == 0) {
                    root.close();
                } else {
                    root.open();
                }
            }
        }
    }
}
