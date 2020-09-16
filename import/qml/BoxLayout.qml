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

GridLayout {
    id: root
    property int orientation: width > height ? Qt.Horizontal : Qt.Vertical
    property bool enforceUniformSizes: true
    columns: orientation === Qt.Horizontal ? Infinity : 1
    rows: orientation === Qt.Vertical ? 1 : Infinity

    onWidthChanged: sizingTimer.restart()
    onHeightChanged: sizingTimer.restart()

    Timer {
        id: sizingTimer
        interval: 0
        onTriggered: {
            if (!root.enforceUniformSizes) {
                return;
            }
            if (root.orientation === Qt.Horizontal) {
                for (let i in root.children) {
                    root.children[i].Layout.preferredWidth = root.width//(root.width - (root.columnSpacing * root.children.length - 1)) / root.children.length;
                    root.children[i].Layout.minimumWidth = -1;
                    root.children[i].Layout.maximumWidth = -1;

                    root.children[i].Layout.preferredHeight = -1;
                    root.children[i].Layout.alignmnent = Qt.AlignCenter;
                    root.children[i].Layout.fillWidth = true;
                    root.children[i].Layout.fillHeight = true;
                }
            } else {
                for (let i in root.children) {
                    root.children[i].Layout.preferredHeight = root.height//(root.height - (root.rowSpacing * root.children.length - 1)) / root.children.length;

                    root.children[i].Layout.preferredWidth = -1;
                    root.children[i].Layout.alignmnent = Qt.AlignCenter;
                    root.children[i].Layout.fillWidth = true;
                    root.children[i].Layout.fillHeight = true;
                }
            }
        }
    }
}
