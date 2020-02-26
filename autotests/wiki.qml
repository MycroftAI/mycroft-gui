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
    id: root
    skillBackgroundSource: "https://source.unsplash.com/1920x1080/?+books"

    ColumnLayout {
        id: lay
        anchors.fill: parent
        Item {
            Layout.preferredHeight: Kirigami.Units.largeSpacing * 5
        }
        Controls.Control {
            padding: Kirigami.Units.largeSpacing
            Layout.preferredWidth: Math.round(Math.min(root.width, root.height) / 2)
            Layout.preferredHeight: Layout.preferredWidth / (image.sourceSize.width/image.sourceSize.height)
            Layout.alignment: Qt.AlignHCenter
            contentItem: Image {
                id: image
                
                source: sessionData.image
            }
            background: Rectangle {
                color: Kirigami.Theme.textColor
                radius: Kirigami.Units.gridUnit / 4
            }
        }
        Kirigami.Heading {
            text: sessionData.title
        }
        Controls.Label {
            Layout.fillWidth: true
            text: sessionData.text
            wrapMode: Text.WordWrap
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
