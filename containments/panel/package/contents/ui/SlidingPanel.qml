/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
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
        colorGroup: {
            switch(Kirigami.Theme.colorSet) {
            case Kirigami.Theme.Window:
                return PlasmaCore.Theme.NormalColorGroup;
            case Kirigami.Theme.Button:
                return PlasmaCore.Theme.ButtonColorGroup;
            case Kirigami.Theme.View:
                return PlasmaCore.Theme.ViewColorGroup;
            case Kirigami.Theme.Selection:
                return PlasmaCore.Theme.NormalColorGroup;
            case Kirigami.Theme.Tooltip:
                return PlasmaCore.Theme.ComplementaryColorGroup;
            case Kirigami.Theme.Complementary:
                return PlasmaCore.Theme.ComplementaryColorGroup;
            }
        }

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
                onDelegateClicked: root.close();
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
