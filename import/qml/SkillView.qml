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

    readonly property Item currentItem: mainStack.currentItem ? mainStack.currentItem.view.currentItem : null
    property int switchWidth: Kirigami.Units.gridUnit * 30

    property alias backgroundVisible: background.visible

    Private.ImageBackground {
        id: background
        delegatesView: mainStack.currentItem ? mainStack.currentItem.view : null
    }

    Timer {
        id: eventCompression
        interval: 500
        property Item delegate
        onTriggered: {
            delegate.visible = true;
            mainStack.replace(delegate);
        }
    }

    Controls.StackView {
        id: mainStack
        anchors.fill: parent
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
            property alias view: delegatesView
            onCurrentChanged: {
                if (index == 0) {
                    eventCompression.delegate = delegate;
                    eventCompression.restart();
                }
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

                onMovementEnded: currentIndex = indexAt(contentX, 0);
                onFlickEnded: movementEnded()
                Connections {
                    target: delegates
                    onCurrentIndexChanged: {
                        delegatesView.currentIndex = delegates.currentIndex
                    }
                }
                delegate: Controls.Control {
                    id: delegate
                    width: Math.max(0, delegatesView.width /  Math.min(delegatesView.count, Math.ceil(delegatesView.width / root.switchWidth)))
                    height: parent.height
                    z: delegatesView.currentIndex == index ? 1 : 0
                    contentItem: model.delegateUi
                    Connections {
                        target: model.delegateUi
                        onEvent: {
                            if (eventName == "page_gained_focus" && data.number == index) {
                                delegatesView.currentIndex = index;
                            }
                        }
                        onFocusChanged: {
                            if (model.delegateUi.focus) {
                                delegatesView.currentIndex = index;
                            }
                        }
                    }
                    Connections {
                        target: delegatesView
                        onCurrentIndexChanged: {
                            if (index == delegatesView.currentIndex && root.width >= root.switchWidth) {
                                focusAnim.restart();
                            }
                        }
                    }
                    SequentialAnimation {
                        id: focusAnim
                        NumberAnimation {
                            target: delegate
                            property: "scale"
                            from: 1
                            to: 1.1
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutBack
                        }
                        NumberAnimation {
                            target: delegate
                            property: "scale"
                            from: 1.1
                            to: 1
                            duration: Kirigami.Units.longDuration *2
                            easing.type: Easing.OutBounce
                        }
                    }
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
