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

import QtQuick 2.10
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.7 as Kirigami
import Mycroft 1.0 as Mycroft

import "private" as Private

Mycroft.AbstractSkillView {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    readonly property Item currentItem: activeSkillsRepeater.currentDelegate ? activeSkillsRepeater.currentDelegate.view.currentItem : null

    property int switchWidth: Kirigami.Units.gridUnit * 45
    property alias backgroundVisible: background.visible

    property int leftPadding: 0
    property int topPadding: 0
    property int rightPadding: 0
    property int bottomPadding: 0

    property bool open: true

    onOpenChanged: {
        if (open) {
            closeAnimation.running = false;
            openAnimation.restart();
        } else {
            openAnimation.running = false;
            closeAnimation.restart();
        }
    }

    Connections {
        target: root.activeSkills
        onSkillActivated: root.open = true;
    }

    SequentialAnimation {
        id: openAnimation
        ScriptAction {
            script: {
                root.visible = true
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            YAnimator {
                target: delegatesContainer
                from: root.height / 4
                to: root.topPadding
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    SequentialAnimation {
        id: closeAnimation
        ParallelAnimation {
            OpacityAnimator {
                target: root
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            YAnimator {
                target: delegatesContainer
                from: root.topPadding
                to: root.height / 4
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                root.visible = false;
            }
        }
    }

    Private.ImageBackground {
        id: background
        delegatesView: activeSkillsRepeater.currentDelegate ? activeSkillsRepeater.currentDelegate.view : null
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    Item {
        id: delegatesContainer
        width: root.width - root.leftPadding - root.rightPadding
        height: root.height - root.topPadding - root.bottomPadding
        x: root.leftPadding
        y: root.topPadding

        Repeater {
            id: activeSkillsRepeater
            property Item currentDelegate
            property Item oldDelegate
            model: activeSkills

            delegate: Item {
                id: delegate
                readonly property bool current: index == activeSkills.activeIndex
                property alias view: delegatesView

                width: parent.width
                height: parent.height

                visible: current || opacityAnim.running
                enabled: current && visible
                opacity: current
                z: current ? 1 : 0

                onCurrentChanged: {
                    activeSkillsRepeater.currentDelegate = delegate;

                    if (current && delegatesView.count === 0) {
                        root.open = false;
                    }
                }
                Behavior on opacity {
                    OpacityAnimator {
                        id: opacityAnim
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                YAnimator {
                    id: enterAnim
                    target: delegate
                    from: root.height / 4
                    to: root.topPadding
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }

                Kirigami.ColumnView {
                    id: delegatesView
                    interactive: true
                    clip: true

                    columnWidth: Math.max(Math.floor(width / Math.floor(width/(switchWidth / 2))), Math.floor(width / count))
                    columnResizeMode: width < root.switchWidth ? Kirigami.ColumnView.SingleColumn : Kirigami.ColumnView.FixedColumns
                    separatorVisible: false
                    anchors.fill: parent

                    onCountChanged: {
                        if (delegate.current && delegatesView.count > 0) {
                            activeSkillsRepeater.currentDelegate = delegate;
                            if (root.open === false) {
                                root.open = true;
                                enterAnim.restart();
                            }
                        }

                        if (count > 0 && currentIndex < 0) {
                            currentIndex = 0;
                        }
                    }
                    onCurrentIndexChanged: {
                        delegates.currentIndex = currentIndex
                    }

                    Keys.onLeftPressed: {
                        delegatesView.currentIndex--
                        delegatesView.currentItem.contentItem.forceActiveFocus()
                    }
                    Keys.onRightPressed: {
                        delegatesView.currentIndex++
                        delegatesView.currentItem.contentItem.forceActiveFocus()
                    }
                    
                    function globalBackRequest(){
                        if(delegatesView.currentIndex !== 0){
                            delegatesView.currentIndex--
                            delegatesView.currentItem.contentItem.forceActiveFocus()
                        } else {
                            Mycroft.MycroftController.sendRequest("mycroft.gui.screen.close", {})
                        }
                    }

                    Connections {
                        target: delegates
                        onCurrentIndexChanged: {
                            delegatesView.currentIndex = delegates.currentIndex
                        }
                    }

                    Repeater {
                        model: delegates

                        delegate: Controls.Control {
                            id: delegate

                            Kirigami.ColumnView.reservedSpace: 0
                            Kirigami.ColumnView.fillWidth: model.delegateUi ? model.delegateUi.fillWidth : false

                            leftPadding: 0
                            rightPadding: 0
                            topPadding: 0
                            bottomPadding: 0
                            width: Math.max(0, delegatesView.width /  Math.min(delegatesView.count, Math.ceil(delegatesView.width / root.switchWidth)))
                            height: parent.height
                            z: delegatesView.currentIndex == index ? 1 : 0
                            contentItem: model.delegateUi
                            padding: 0
                            visible: x + width >= delegatesView.contentX || x >= delegatesView.contentX + delegatesView.width
                            property int extraBottomPadding: pageIndicator.visible ? Kirigami.Units.largeSpacing * 2 + pageIndicator.height : 0
                            signal backRequested
                                                        
                            Component.onCompleted: {
                                    backRequested.connect(delegatesView.globalBackRequest)
                            }
                            
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
                                visible: root.width >= root.switchWidth && delegatesView.count > 1 && (model.delegateUi && !model.delegateUi.fillWidth)
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
                }
                Controls.PageIndicator {
                    id: pageIndicator
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
