/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
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
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "News item from a newspaper"
                }
            }
            WeatherItem {}
            ItemBase {
                Kirigami.Heading {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
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

