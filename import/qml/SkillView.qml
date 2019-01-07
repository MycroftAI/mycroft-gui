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
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

import "private" as Private

Mycroft.AbstractSkillView {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    readonly property Item currentItem: activeSkillsRepeater.currentDelegate ? activeSkillsRepeater.currentDelegate.view.currentItem : null
    
    property int switchWidth: Kirigami.Units.gridUnit * 30

    property alias backgroundVisible: background.visible

    Private.ImageBackground {
        id: background
        delegatesView: activeSkillsRepeater.currentDelegate ? activeSkillsRepeater.currentDelegate.view : null
    }

    Timer {
        id: eventCompression
        interval: 500
        property Item delegate
        onTriggered: {
            enterAnimation.restart();
            exitAnimation.restart();
            print(enterAnimation.target)
        }
    }

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation {
            target: activeSkillsRepeater.currentDelegate
            property: "opacity"
            from: 0
            to: 1
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        YAnimator {
            target: activeSkillsRepeater.currentDelegate
            from: root.height / 4
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    OpacityAnimator {
        id: exitAnimation
        target: activeSkillsRepeater.oldDelegate
        from: 1
        to: 0
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
    }

    Repeater {
        id: activeSkillsRepeater
        property Item currentDelegate
        property Item oldDelegate
        model: activeSkills

        delegate: Item {
            id: delegate
            readonly property bool current: index == 0
            property alias view: delegatesView
            width: parent.width
            height: parent.height
            opacity: 0
            onCurrentChanged: {
                if (index == 0) {
                    activeSkillsRepeater.oldDelegate = activeSkillsRepeater.currentDelegate;
                    activeSkillsRepeater.currentDelegate = delegate;
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
                    enabled: root.width > root.switchWidth
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                displaced: Transition {
                    enabled: root.width > root.switchWidth
                    XAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                moveDisplaced: Transition {
                    enabled: root.width > root.switchWidth
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
                        onFocusChanged: {
                            if (model.delegateUi.focus) {
                                delegatesView.currentIndex = index;
                                if (root.width >= root.switchWidth) {
                                    focusAnim.restart();
                                }
                            }
                        }
                    }

                    SequentialAnimation {
                        id: focusAnim
                        NumberAnimation {
                            target: model.delegateUi
                            property: "scale"
                            from: 1
                            to: 1.1
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: model.delegateUi
                            property: "scale"
                            from: 1.1
                            to: 1
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    RadialGradient {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: Kirigami.Units.gridUnit
                        verticalOffset: height/2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Kirigami.Theme.highlightColor }
                            GradientStop { position: 0.5; color: "transparent" }
                        }
                        visible: root.width >= root.switchWidth && delegatesView.count > 1
                        opacity: delegatesView.currentIndex == index
                        Behavior on opacity {
                            NumberAnimation {
                                property: "scale"
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }
            Controls.PageIndicator {
                //visible: delegatesView.count > 1
                visible: false
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
