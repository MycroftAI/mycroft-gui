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

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import QtQuick.Templates 2.2 as T
import org.kde.kirigami 2.5 as Kirigami

Controls.Control {
    id: root

    property alias iconSource: icon.source
    property alias slider: slider

    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

    //Layout.preferredWidth: Kirigami.Units.gridUnit * 5
    Layout.fillWidth: true
    Layout.preferredHeight: Kirigami.Units.gridUnit * 15
    contentItem: Item {
        ColumnLayout {
            anchors {
                top: parent.top
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Kirigami.Icon {
                    id: icon
                    isMask: true
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Layout.preferredWidth
                }
                Controls.Label {
                    text: Math.round(slider.position * 10)
                    Layout.preferredWidth: textMetrics.width
                    TextMetrics {
                        id
                        : textMetrics
                        text: "10"
                    }
                }
            }
            T.Slider {
                id: slider
                orientation: Qt.Vertical
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                Layout.fillHeight: true
                handle: Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: slider.height - slider.position * (slider.height - height) - height
                    color: "orange"
                    radius: height
                    implicitWidth: Kirigami.Units.gridUnit * 3
                    implicitHeight: Kirigami.Units.gridUnit
                }
                background: Item {
                    Rectangle {
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: Math.round(Kirigami.Units.gridUnit / 2)
                        color: Qt.rgba(0.2, 0.2, 0.2, 0.6)
                        radius: width
                        Rectangle {
                            color: Kirigami.Theme.highlightColor
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            radius: width
                            height: slider.position * (slider.height - width) + width
                        }
                    }
                }
            }
        }
    }

    background: Rectangle {
        radius: Kirigami.Units.largeSpacing
        color: PlasmaCore.ColorScope.backgroundColor
    }
}
