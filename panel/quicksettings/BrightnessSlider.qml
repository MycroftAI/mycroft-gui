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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.5 as Kirigami

RowLayout {
    id: root

    property int screenBrightness
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0

    spacing: Kirigami.Units.smallSpacing

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source);
                connectSource(source);
            }
        }

        onDataChanged: {
            root.screenBrightness = pmSource.data["PowerDevil"]["Screen Brightness"];
        }
    }

    Kirigami.Icon {
        //TODO: put in theme
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Layout.preferredWidth
        source: Qt.resolvedUrl("./brightness-decrease.svg")
    }

    Controls.Slider {
        id: brightnessSlider
        Layout.fillWidth: true
        value: root.screenBrightness
        onMoved: {
            var service = pmSource.serviceForSource("PowerDevil");
            var operation = service.operationDescription("setBrightness");
            operation.brightness = value;
            operation.silent = true
            service.startOperationCall(operation);
        }
        from: to > 100 ? 1 : 0
        to: root.maximumScreenBrightness
    }

    Kirigami.Icon {
        //TODO: put in theme
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Layout.preferredWidth
        source: Qt.resolvedUrl("./brightness-increase.svg")
    }
}

