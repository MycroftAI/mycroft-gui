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
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        
        width: height * (sourceSize.width / sourceSize.height)
        source: "https://source.unsplash.com/1920x1080/?+mountains"
    }

    Timer {
        id: eventCompression
        interval: 500
        property Item delegate
        onTriggered: {
            mainStack.replace(delegate);
        }
    }
    Controls.StackView {
        id: mainStack
        anchors.fill: parent
        initialItem: Item {}
        replaceEnter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
                YAnimator {
                    from: mainStack.height / 4
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        replaceExit: Transition {
            PauseAnimation {
                duration: Kirigami.Units.longDuration
            }
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
    Repeater {
        id: activeSkillsRepeater
        model: activeSkills

        delegate: Item {
            id: delegate
            readonly property bool current: index == 0
            onCurrentChanged: {
                if (index == 0) {
                    eventCompression.delegate = delegate;
                    eventCompression.restart();
                }
            }

            Private.ImageBackground {
                id: imageBackground
            }
            ListView {
                id: delegatesView
                interactive: true
                clip: true
                cacheBuffer: width * 2
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

                move: Transition {
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                displaced: Transition {
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                moveDisplaced: Transition {
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                removeDisplaced: Transition {
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                remove: Transition {
                    ParallelAnimation {
                        OpacityAnimator {
                            from: 1
                            to: 0
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InQuad
                        }
                        YAnimator {
                            from: 0
                            to: -delegatesView.height / 3
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InQuad
                        }
                    }
                }

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
                    width: Math.max(0, delegatesView.width /  Math.min(delegatesView.count, Math.ceil(delegatesView.width / (Kirigami.Units.gridUnit * 30))))
                    height: parent.height
                    contentItem: model.delegateUi
                    Component.onCompleted: delegatesView.currentIndex = 1
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
