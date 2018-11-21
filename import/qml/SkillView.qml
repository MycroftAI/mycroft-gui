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

Mycroft.AbstractSkillView {
    id: root

    property Item initialItem: null
    onInitialItemChanged: {
        initialItem.parent = restFaceParent;
        initialItem.anchors.fill = restFaceParent;
    }

    readonly property Item currentItem: null

    function goBack() {
        
    }

    Controls.SwipeView {
        id: restFaceSwipeView
        anchors.fill: parent
        Item {
            id: restFaceParent
            width: restFaceSwipeView.width
            height: restFaceSwipeView.height
            Text {
                text: "resting face"
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
                    Item {
                        id: backgroundImage
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: parent.width * 2
                        x: -delegatesView.visibleArea.xPosition * 1.5 * parent.width

                        property string source
                        property Image currentImage: image1
                        onSourceChanged: {
                            if (backgroundImage.currentImage == image1) {
                                image2.opacity = 0;
                                image2.source = source;
                                if (image2.status == Image.Ready) {
                                    backgroundImage.setCurrent(image2);
                                }
                            } else {
                                image1.opacity = 0;
                                image1.source = source;
                                if (image1.status == Image.Ready) {
                                    backgroundImage.setCurrent(image1);
                                }
                            }
                        }

                        function setCurrent(image) {
                            backgroundImage.currentImage = image;
                            fadeAnim.restart();
                        }
                        
                        Image {
                            id: image1
                            anchors.fill: parent
                            z: backgroundImage.currentImage == image1 ? 1 : 0
                            onStatusChanged: {
                                if (backgroundImage.currentImage == image2 && status == Image.Ready) {
                                    backgroundImage.setCurrent(image1);
                                }
                            }
                        }
                        Image {
                            id: image2
                            anchors.fill: parent
                            z: backgroundImage.currentImage == image2 ? 1 : 0
                            onStatusChanged: {
                                if (backgroundImage.currentImage == image1 && status == Image.Ready) {
                                    backgroundImage.setCurrent(image2);
                                }
                            }
                        }
                        SequentialAnimation {
                            id: fadeAnim
                            OpacityAnimator {
                                target: backgroundImage.currentImage
                                from: 0
                                to: 1
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                        }
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
                                backgroundImage.source = background;
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
                            width: Math.max(0, restFaceSwipeView.width /  Math.ceil(restFaceSwipeView.width / (Kirigami.Units.gridUnit * 30)))
                            height: parent.height
                            contentItem: model.delegateUi
                            Component.onCompleted: restFaceSwipeView.currentIndex = 1
                        }
                    }
                }
            }
        }
    }
}
