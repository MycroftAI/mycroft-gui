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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

Controls.Control {
    id: delegateRoot
    property bool toggled
    property alias iconSource: icon.source
    property alias text: label.text

    signal clicked(var mouse)

    leftPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    implicitWidth: Kirigami.Units.iconSizes.medium * 2 + leftPadding + rightPadding
    implicitHeight: implicitWidth + topPadding + bottomPadding

    contentItem: ColumnLayout {
        PlasmaCore.IconItem {
            id: icon
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.fillWidth: true
            colorGroup: PlasmaCore.ColorScope.colorGroup
        }
        PlasmaComponents.Label {
            id: label
            Layout.fillWidth: true
            text: model.text
            //visible: paintedWidth <= parent.width
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
    background: Rectangle {
        radius: Kirigami.Units.smallSpacing
        opacity: iconMouseArea.pressed ? 0.5 : 0.3
        color: toggled ? PlasmaCore.ColorScope.highlightColor : PlasmaCore.ColorScope.textColor
    }
    MouseArea {
        id: iconMouseArea
        anchors.fill: parent
        onClicked: delegateRoot.clicked(mouse)
    }
}

