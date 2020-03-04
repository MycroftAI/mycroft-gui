/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
 * Copyright 2018 David Edmundson <davidedmundson@kde.org>
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
import QtQuick 2.4
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

//TODO: should all delegates be a Kirigami Page?
Mycroft.AbstractDelegate {
    id: control

    signal backRequested

    skillBackgroundColorOverlay: Kirigami.Theme.textColor.hsvValue > 0.5 ? Qt.rgba(0,0,0, 0.4) : Qt.rgba(1,1,1, 0.4)

    property Component controlBar

    readonly property Item controlBarItem: {
        if (controlBar) {
            return controlBar.createObject(control, {"z": 9999});
        } else {
            return null;
        }
    }

    //To do some automatic responsive layouting
    readonly property bool wideMode: width > Kirigami.Units.gridUnit * 18

    leftPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
}
