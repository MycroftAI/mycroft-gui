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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.5 as Kirigami

Controls.Control {
    id: delegateRoot
    property bool toggled
    property alias iconSource: icon.source
    property alias text: label.text

    signal clicked(var mouse)

    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    implicitWidth: Kirigami.Units.iconSizes.medium * 2 + leftPadding + rightPadding
    implicitHeight: implicitWidth + topPadding + bottomPadding

    Layout.fillWidth: true

    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing
        Kirigami.Icon {
            id: icon
            isMask: true
            color: Kirigami.Theme.highlightColor
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.fillHeight: true
        }
        Controls.Label {
            id: label
            Layout.fillWidth: true
            text: model.text
            //visible: paintedWidth <= parent.width
            elide: Text.ElideRight
        }
    }
    background: Rectangle {
        radius: Kirigami.Units.largeSpacing
        color: toggled ? PlasmaCore.ColorScope.highlightColor : PlasmaCore.ColorScope.backgroundColor
    }
    MouseArea {
        id: iconMouseArea
        anchors.fill: parent
        onClicked: {
            delegateRoot.clicked(mouse);
            root.delegateClicked();
        }
    }
}

