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

import QtQuick 2.4
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

import "private" as Private

Mycroft.AbstractSkillView {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    property Item initialItem: null
    onInitialItemChanged: {
        initialItem.parent = restFaceParent;
        initialItem.anchors.fill = restFaceParent;
    }

    readonly property Item currentItem: null

    function goBack() {
        
    }

    //FIXME: placeholder, to remove
    Image {
        id: image1
        anchors.fill: parent
        source: "https://source.unsplash.com/1920x1080/?+mountains"
    }

    Controls.SwipeView {
        id: restFaceSwipeView
        anchors.fill: parent
        Item {
            id: restFaceParent
            width: restFaceSwipeView.width
            height: restFaceSwipeView.height
            Text {
                text: "13:37"
                color: "white"
                font.pointSize: 44
                style: Text.Outline
                anchors.centerIn: parent
            }
        }

        Item {
            width: restFaceSwipeView.width
            height: restFaceSwipeView.height
            Repeater {
                id: activeSkillsRepeater
                model: activeSkills
                
                delegate: Item {
                    anchors.fill: parent
                    opacity: Math.min(1, restFaceSwipeView.contentItem.contentX/width)
                    Private.ImageBackground {
                        id: imageBackground
                    }
                    ListView {
                        id: delegatesView
                        interactive: true
                        cacheBuffer: contentWidth * 2
                        anchors.fill: parent
                        orientation: ListView.Horizontal
                        boundsBehavior: Flickable.StopAtBounds
                        snapMode: ListView.SnapToItem
                        preferredHighlightBegin: 0
                        preferredHighlightEnd: 0
                        highlightMoveDuration: Kirigami.Units.longDuration
                        highlightFollowsCurrentItem: true
                        model: delegates
                        visible: index == 0

                        onCurrentIndexChanged: {
                            delegates.currentIndex = currentIndex
                        }
                        onCurrentItemChanged: {
                            var background = currentItem.contentItem.skillBackgroundSource;
                            if (background.length > 0) {
                                imageBackground.source = background;
                            }
                        }
                        onMovementEnded: currentIndex = indexAt(contentX, 0);
                        onFlickEnded: movementEnded()
                        Connections {
                            target: delegates
                            onCurrentIndexChanged: {
                                delegatesView.currentIndex = delegates.currentIndex
                            }
                        }
                        delegate: Controls.Control {
                            width: Math.max(0, restFaceSwipeView.width /  Math.min(delegatesView.count, Math.ceil(restFaceSwipeView.width / (Kirigami.Units.gridUnit * 30))))
                            height: parent.height
                            contentItem: model.delegateUi
                            Component.onCompleted: restFaceSwipeView.currentIndex = 1
                        }
                    }
                    Controls.PageIndicator {
                        visible: delegatesView.count > 1
                        z: 999
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            margins: Kirigami.Units.largeSpacing
                        }
                        count: delegatesView.count
                        currentIndex: delegatesView.currentIndex
                    }
                }
            }
        }
    }
}
