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

    property bool peeking: false

    property Item bottomItem

    onBottomItemChanged: {
        bottomItem.parent = contentArea;
        bottomItem.anchors.fill = contentArea;
    }

    onVisibleChanged: flickable.contentY = 0
    opacity: position

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    contentItem: PlasmaCore.ColorScope {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        colorGroup: PlasmaCore.Theme.ViewColorGroup

        implicitWidth: layout.implicitWidth + Kirigami.Units.largeSpacing * 2
        implicitHeight: root.parent.height//layout.implicitHeight + Kirigami.Units.largeSpacing * 2
        Flickable {
            id: flickable
            anchors {
                fill: parent
                margins: Kirigami.Units.largeSpacing * 2
            }
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: width
            contentHeight: layout.height
            ColumnLayout {
                id: layout

                width: parent.width
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
    }
    background: Item {}

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
