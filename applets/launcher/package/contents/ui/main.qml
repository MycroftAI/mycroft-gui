/*
 * Copyright 2018 Kai Uwe Broulik <kde@broulik.de>
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

import QtQuick 2.8
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {

    GridView {
        id: grid

        readonly property int columnCount: Math.floor(width / (units.gridUnit * 10))
        readonly property int rowCount: 2

        anchors.fill: parent
        interactive: false

        cellWidth: Math.floor(width / columnCount)
        cellHeight: Math.floor(height / rowCount)

        model: plasmoid.nativeInterface.applicationsModel

        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight

            MouseArea {
                id: delegateArea
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width, parent.height)
                height: width
                hoverEnabled: true // needed?
                onClicked: plasmoid.nativeInterface.applicationsModel.launch(index)

                ColumnLayout {
                    anchors.fill: parent
                    spacing: units.smallSpacing

                    PlasmaCore.IconItem {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        usesPlasmaTheme: false
                        source: model.decoration
                        active: delegateArea.containsMouse
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        text: model.display
                    }
                }
            }
        }
    }
}
