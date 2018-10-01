/*
 * Copyright 2018 Kai Uwe Broulik <kde@broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
