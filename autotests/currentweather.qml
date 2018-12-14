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
 
import QtQuick 2.4
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    skillBackgroundSource: "https://source.unsplash.com/1920x1080/?+sun"

    function updateTemperature(temp) {
        sessionData.temperature = temp;
    }

    function deleteProperty() {
        sessionData.to_delete = null;
    }

    ColumnLayout {
        anchors.fill: parent
        Kirigami.Heading {
            text: "Today"
        }
        Kirigami.Icon {
            source: sessionData.icon
            Layout.preferredWidth: Kirigami.Units.iconSizes.huge
            Layout.preferredHeight: Layout.preferredWidth
        }
        Controls.Label {
            text: "icon: " + sessionData.icon
        }
        Controls.Label {
            text: "temperature: " + sessionData.temperature
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
