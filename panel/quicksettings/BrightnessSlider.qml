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

import QtQuick 2.9
import org.kde.plasma.core 2.0 as PlasmaCore

SliderBase {
    id: root

    leftIconSource: Qt.resolvedUrl("./brightness-decrease.svg")
    rightIconSource: Qt.resolvedUrl("./brightness-increase.svg")

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

    slider.value: root.screenBrightness
    slider.onMoved: {
        var service = pmSource.serviceForSource("PowerDevil");
        var operation = service.operationDescription("setBrightness");
        operation.brightness = slider.value;
        operation.silent = true
        service.startOperationCall(operation);
    }
    slider.from: slider.to > 100 ? 1 : 0
    slider.to: root.maximumScreenBrightness
}

