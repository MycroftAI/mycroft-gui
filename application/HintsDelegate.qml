/*
 * Copyright 2018 Marco Martin <mart@kde.org>
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.11 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Kirigami.AbstractCard {
    id: skillDelegate
    property string imageSource
    property string title
    property string category
    property variant examples

    contentItem: Item {
        implicitWidth: delegateLayout.implicitWidth;
        implicitHeight: delegateLayout.implicitHeight;

        ColumnLayout {
            id: delegateLayout
            anchors {
                left: parent.left;
                top: parent.top;
                right: parent.right;
            }

            Kirigami.Heading {
                id: skillName
                Layout.fillWidth: true;
                wrapMode: Text.WordWrap;
                font.bold: true;
                text: qsTr(title);
                level: 3;
                color: Kirigami.Theme.textColor;
            }

            RowLayout {
                id: skillTopRowLayout
                spacing: Kirigami.Units.largeSpacing
                Layout.fillWidth: true;

                Image {
                    id: innerskImg
                    source: imageSource;
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredWidth: innerskImg.width
                    Layout.preferredHeight: innerskImg.height
                    width: Kirigami.Units.gridUnit * 2
                    height: Kirigami.Units.gridUnit * 2
                    ColorOverlay {
                        id: colorOverlay
                        source: innerskImg
                        color: Kirigami.Theme.linkColor
                        anchors.fill: parent
                    }

                }

                ColumnLayout {
                    id: innerskillscolumn
                    spacing: 2;
                    Controls.Label {
                        wrapMode: Text.WordWrap;
                        width: skillDelegate.width;
                        color: Kirigami.Theme.textColor;
                        text: examples[1];
                    }
                    Controls.Label {
                        wrapMode: Text.WordWrap;
                        width: skillDelegate.width;
                        color: Kirigami.Theme.textColor;
                        text: examples[2];
                    }
                }
            }
        }
    }
}
