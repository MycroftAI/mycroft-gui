/*
 * Copyright 2019 by Marco Martin <mart@kde.org>
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

import QtQuick 2.4
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Delegate {
    id: root

    property int unitDensity: 100
    property real proportionalGridUnit: Math.min(root.contentWidth, root.contentHeight) / unitDensity
    property int spacing: proportionalGridUnit * 10
    property alias enforceUniformSizes: layout.enforceUniformSizes

    leftPadding: Math.min(root.width, root.height)/15
    topPadding: Math.min(root.width, root.height)/15
    rightPadding: Math.min(root.width, root.height)/15
    bottomPadding: Math.min(root.width, root.height)/15 + root.parent.extraBottomPadding

    //contentItemAutoHeight: false
    contentItem: Mycroft.BoxLayout {
        id: layout

        //TODO: default to zero?
        rowSpacing: root.spacing
        columnSpacing: root.spacing
    }
}
