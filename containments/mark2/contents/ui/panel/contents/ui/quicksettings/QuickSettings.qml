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
import QtQuick.Window 2.2
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    id: root

    signal delegateClicked

    function toggleAirplane() {
        print("toggle airplane mode")
    }

    spacing: units.largeSpacing
    property Controls.Drawer drawer

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing * 2
        BrightnessSlider {
            Layout.fillWidth: true
        }
        VolumeSlider {
            Layout.fillWidth: true
        }
    }

    ColumnLayout {
        id: buttonsLayout
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        spacing: Kirigami.Units.largeSpacing * 2

        property int delegateSize: Kirigami.Units.iconSizes.medium * 2 + Kirigami.Units.smallSpacing*2

        HomeDelegate {}
        DisableMycroftDelegate {}
        SystemSettingsDelegate {}
    }
}
