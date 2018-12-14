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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Window 2.2
import Mycroft 1.0 as Mycroft
import org.kde.private.mycroftgui 1.0 as MycroftGui

Kirigami.ApplicationWindow {
    id: root
    visible: true

    minimumHeight : deviceHeight || undefined
    maximumHeight : deviceHeight || undefined
    minimumWidth : deviceWidth || undefined
    maximumWidth : deviceWidth || undefined
    x: deviceWidth ? Screen.desktopAvailableHeight - width : undefined
    y: deviceHeight ? Screen.desktopAvailableHeight - height : undefined

    //HACK!! needs proper api in kirigami
    Component.onCompleted: {
        globalDrawer.handle.handleAnchor = handleAnchor;
        
        //HACK for the hacky top panel, on android will fail silently
        var component = Qt.createComponent(Qt.resolvedUrl("containments/panel/package/contents/ui/SlidingPanel.qml"));
        var panel = component.createObject(root);
        panel.Kirigami.Theme.colorSet = Kirigami.Theme.Complementary;
        panel.width = Qt.binding(function(){return root.width});
    }

    // Uses Android's voice popup for speech recognition
    MycroftGui.SpeechIntent {
        id: speechIntent
        title: "Say something to Mycroft" // TODO i18n
        onSpeechRecognized: {
            Mycroft.MycroftController.sendText(text)
        }
        //onRecognitionFailed: console.log("SPEECH FAILED")
        //onRecognitionCanceled: console.log("SPEECH CANCELED")
        //onNothingRecognized: console.log("SPEECH NOTHING")
    }

    //HACK
    Connections {
        target: root.pageStack.layers
        onDepthChanged: {
            if (root.pageStack.layers.depth == 1) {
                globalDrawer.handle.handleAnchor = handleAnchor;
            } else {
                globalDrawer.handle.handleAnchor = null;
            }
        }
    }

    globalDrawer: Kirigami.GlobalDrawer {
        bannerImageSource: "banner.png"
        handleVisible: !hideTextInput

        actions: [
            Kirigami.Action {
                text: "Hints"
                iconName: "help-hint"
                checked: pageStack.layers.currentItem.objectName == "hints"
                onTriggered: {
                    if (checked) {
                        pageStack.layers.pop(pageStack.layers.initialItem);
                    } else if (pageStack.layers.depth > 1) {
                        pageStack.layers.replace(Qt.resolvedUrl("HintsPage.qml"));
                    } else {
                        pageStack.layers.push(Qt.resolvedUrl("HintsPage.qml"));
                    }
                }
            },
            Kirigami.Action {
                text: "Settings"
                iconName: "configure"
                checked: pageStack.layers.currentItem.objectName == "Settings"
                onTriggered: {
                    if (checked) {
                        pageStack.layers.pop(pageStack.layers.initialItem);
                    } else if (pageStack.layers.depth > 1) {
                        pageStack.layers.replace(Qt.resolvedUrl("SettingsPage.qml"));
                    } else {
                        pageStack.layers.push(Qt.resolvedUrl("SettingsPage.qml"));
                    }
                }
            }
        ]
    }


    pageStack.globalToolBar.style: pageStack.layers.depth == 1 ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.Auto

    pageStack.initialPage: Kirigami.Page {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        onBackRequested: {
            if (mainView.active) {
                event.accepted = true;
                mainView.goBack();
            }
        }
        Image {
            source: "background.png"
            anchors.fill: parent

            Mycroft.SkillView {
                id: mainView
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                anchors.fill: parent
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Button {
                anchors.centerIn: parent
                text: "start"
                visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Closed
                onClicked: Mycroft.MycroftController.start();
            }

            Mycroft.StatusIndicator {
                id: si
                visible: true
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: Kirigami.Units.largeSpacing
                }
                z: 999
            }
        }

        //Note: a custom control as ToolBar on Android has a funny color
        footer: Control {
            visible: !hideTextInput
            implicitHeight: contentItem.implicitHeight
            contentItem: RowLayout {
                Item {
                    id: handleAnchor
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                }
                TextField {
                    Layout.fillWidth: true
                    id: qinput
                    onAccepted: {
                        Mycroft.MycroftController.sendText(qinput.text)
                    }

                    Connections {
                        target: speechIntent
                        onSpeechRecognized: qinput.text = text
                    }
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
                }
                Button {
                    text: "Speak" // TODO generic microphone icon
                    onClicked: speechIntent.start()
                    visible: speechIntent.supported
                }
            }
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                LinearGradient {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.top
                    }
                    implicitHeight: Kirigami.Units.gridUnit/2

                    start: Qt.point(0, height)
                    end: Qt.point(0, 0)
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(0, 0, 0, 0.2)
                        }
                        GradientStop {
                            position: 0.3
                            color: Qt.rgba(0, 0, 0, 0.1)
                        }
                        GradientStop {
                            position: 1.0
                            color:  "transparent"
                        }
                    }
                }
            }
        }
    }
}


