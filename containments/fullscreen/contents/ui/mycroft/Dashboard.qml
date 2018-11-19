/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as Controls
import QtGraphicalEffects 1.0
import QtQml.Models 2.1

import org.kde.kirigami 2.5 as Kirigami

Item {
    id: root
    anchors.fill: parent
    PathView {
        id: dashbardView
        anchors.fill: parent

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        pathItemCount: 3
        snapMode: PathView.SnapOneItem

        onCurrentIndexChanged: switchTimer.restart()

        //STUB STUB STUB
        model: ObjectModel {
            ItemBase {
                Kirigami.Heading {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    text: "News item from a newspaper"
                }
            }
            WeatherItem {}
            ItemBase {
                Kirigami.Heading {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    text: "You have an appointment today at 15:30"
                }
            }
        }

        path: Path {
            startX: 0
            startY: root.height/2


            //before middle
            PathLine {
                x: root.width/4
                y:root.height/2
            }
            PathAttribute {
                name: "opacity"
                value: 0
            }

            //middle
            PathLine {
                x: root.width/2
                y:root.height/2
            }
            PathAttribute {
                name: "opacity"
                value: 1
            }

            //after middle
            PathLine {
                x: root.width/4*3
                y:root.height/2
            }
            PathAttribute {
                name: "opacity"
                value:0
            }

            //end
            PathLine {
                x: root.width
                y:root.height/2
            }

        }
    }

    Timer {
        id: switchTimer
        interval: 10000
        running: true
        repeat: true
        onTriggered: dashbardView.currentIndex = (Math.round(dashbardView.currentIndex) + 1) % dashbardView.count
    }

    Controls.PageIndicator {
        visible: dashbardView.visible
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.largeSpacing * 3
        }
        count: dashbardView.count
        currentIndex: dashbardView.currentIndex
    }

}

