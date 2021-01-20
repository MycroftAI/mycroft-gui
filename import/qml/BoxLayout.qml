/*
 * Copyright 2020 by Marco Martin <mart@kde.org>
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
import QtQuick 2.6
import QtQuick.Layouts 1.4
import Mycroft 1.0 as Mycroft

Item {
    id: root
    property alias rowSpacing: lay.rowSpacing
    property alias columnSpacing: lay.columnSpacing

    property int orientation: width > height ? Qt.Horizontal : Qt.Vertical
    property bool enforceUniformSizes: true

    implicitWidth: lay.implicitWidth
    implicitHeight: lay.implicitHeight

    GridLayout {
        id: lay
        anchors.fill: parent

        columns: root.orientation === Qt.Horizontal ? Infinity : 1
        rows: root.orientation === Qt.Vertical ? 1 : Infinity

        Repeater {
            model: root.children.length-1
            delegate: Item {
                Layout.fillWidth: root.enforceUniformSizes ?  true : item.Layout.fillWidth
                Layout.fillHeight: root.enforceUniformSizes ?  true : item.Layout.fillHeight

                Layout.minimumWidth: root.enforceUniformSizes ? 0 : item.Layout.minimumWidth
                Layout.minimumHeight: root.enforceUniformSizes ? 0 : item.Layout.minimumHeight

                Layout.maximumWidth: root.enforceUniformSizes ? Infinity : item.Layout.maximumWidth
                Layout.maximumHeight: root.enforceUniformSizes ? Infinity : item.Layout.maximumHeight

                Layout.preferredWidth: root.enforceUniformSizes ? -1 : item.Layout.preferredWidth
                Layout.preferredHeight: root.enforceUniformSizes ? -1 : item.Layout.preferredHeight

                readonly property Item item: root.children[modelData+1]
                visible: item.visible && !(item instanceof Repeater)
                onItemChanged: syncGeometry()

                function syncGeometry() {
                    item.width = width
                    if (item.implicitHeight > 0
                        && !item.Layout.fillHeight
                        && root.orientation === Qt.Horizontal) {
                        item.height = Math.min(height, item.implicitHeight);
                    } else {
                        item.height = height;
                    }
                    item.x = x
                    
                    if (root.orientation === Qt.Horizontal) {
                        item.y = y + (height - item.height) / 2;
                    } else {
                        item.y = y;
                    }
                }
                onWidthChanged: Qt.callLater(syncGeometry)
                onHeightChanged: Qt.callLater(syncGeometry)
                onXChanged: Qt.callLater(syncGeometry)
                onYChanged: Qt.callLater(syncGeometry)
            }
        }
    }
}
