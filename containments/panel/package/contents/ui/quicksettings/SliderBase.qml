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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

RowLayout {
    spacing: Kirigami.Units.smallSpacing
    property alias leftIconSource: leftIcon.source
    property alias rightIconSource: rightIcon.source
    property alias slider: slider

    Kirigami.Icon {
        id: leftIcon
        isMask: true
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Layout.preferredWidth
    }
    Controls.Slider {
        id: slider
        Layout.fillWidth: true
    }
    Kirigami.Icon {
        id: rightIcon
        isMask: true
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Layout.preferredWidth
    }
}
