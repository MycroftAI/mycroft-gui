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
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Window 2.2
import Mycroft 1.0 as Mycroft
import org.kde.private.mycroftgui 1.0 as MycroftGui
import QtQuick.Controls.Material 2.0

Kirigami.ApplicationWindow {
    id: root
    visible: true

    minimumHeight : deviceHeight || undefined
    maximumHeight : deviceHeight || undefined
    minimumWidth : deviceWidth || undefined
    maximumWidth : deviceWidth || undefined
    x: deviceWidth ? Screen.desktopAvailableHeight - width : undefined
    y: deviceHeight ? Screen.desktopAvailableHeight - height : undefined

    color: "black"
    //HACK!! needs proper api in kirigami
    Component.onCompleted: {
        globalDrawer.handle.handleAnchor = handleAnchor;

        // Maximize and auto connect if set
        if (deviceMaximized) {
            showMaximized()
        }

        //FIXME
        //if (qinput.visible) {
        //    qinput.forceActiveFocus();
        //}

        if (singleSkillHome.length > 0 && Mycroft.MycroftController.status === Mycroft.MycroftController.Open) {
            Mycroft.MycroftController.sendRequest(singleSkillHome, {});
        }
        
        if(!isAndroid && Kirigami.Settings.isMobile){
            applicationSettings.usesRemoteSTT = true
            Mycroft.GlobalSettings.usesRemoteTTS = true
        }
    }

    Connections {
        target: Mycroft.MycroftController
        onStatusChanged: {
            if (singleSkillHome.length > 0 && Mycroft.MycroftController.status === Mycroft.MycroftController.Open) {
                Mycroft.MycroftController.sendRequest(singleSkillHome, {});
            }
        }
        
        onSpeechRequestedChanged: {
            if(expectingResponse) {
                micButton.clicked()
            }
        }
        
        onSkillTimeoutReceived: {
            if(mainView.currentItem.contentItem.skillId() == skillidleid) {
                root.close()
            }
        }
    }
    
    Connections {
        target: keyFilter
        onGlobalBackReceived: {
            mainView.currentItem.backRequested()
        }
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
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: applicationSettings.darkMode ? Kirigami.Theme.Complementary : Kirigami.Theme.View

        actions: [
            Kirigami.Action {
                text: "Hints"
                iconName: "help-hint"
                visible: !Kirigami.Settings.isMobile
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
            },
            Kirigami.Action {
                text: "About"
                iconName: "help-about"
                checked: pageStack.layers.currentItem.objectName == "About"
                onTriggered: {
                    if (checked) {
                        pageStack.layers.pop(pageStack.layers.initialItem);
                    } else if (pageStack.layers.depth > 1) {
                        pageStack.layers.replace(Qt.resolvedUrl("AboutPage.qml"));
                    } else {
                        pageStack.layers.push(Qt.resolvedUrl("AboutPage.qml"));
                    }
                }
            }
        ]
        
        Switch {
            id: nightSwitch
            visible: !Kirigami.Settings.isMobile
            text: "Dark Mode"
            checked: applicationSettings.darkMode
            onCheckedChanged: applicationSettings.darkMode = checked
        }
    }

    Timer {
        interval: 20000
        running: Mycroft.GlobalSettings.autoConnect && Mycroft.MycroftController.status != Mycroft.MycroftController.Open
        triggeredOnStart: true
        onTriggered: {
            print("Trying to connect to Mycroft");
            Mycroft.MycroftController.start();
        }
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
        Rectangle {
            color: nightSwitch.checked ? "black" : Kirigami.Theme.backgroundColor
            rotation: globalScreenRotation || 0
            anchors.fill: parent
            Image {
                visible: singleSkill.length === 0
                source: "background.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                opacity: !mainView.currentItem
                Behavior on opacity {
                    OpacityAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InQuad
                    }
                }
            }

            Popup {
                id: audioRecorder
                width: root.width - (Kirigami.Units.largeSpacing * 2)
                height: root.height / 2
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.View
                parent: root
                x: (root.width - width) / 2
                y: (root.height - height) / 2
                
                background: Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    radius: Kirigami.Units.smallSpacing * 0.25
                    border.width: 1
                    Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.View
                    border.color: Qt.rgba(Kirigami.Theme.disabledTextColor.r, Kirigami.Theme.disabledTextColor.g, Kirigami.Theme.disabledTextColor.b, 0.7)
                }
                
                RemoteStt {
                    id: remoteSttInstance
                }

                onOpenedChanged: {
                    if(audioRecorder.opened){
                        remoteSttInstance.record = true;
                    } else {
                        remoteSttInstance.record = false;
                    }
                }
            }

            Mycroft.SkillView {
                id: mainView
                activeSkills.whiteList: singleSkill.length > 0 ? singleSkill : null
                Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.View
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "start"
                visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Closed
                onClicked: Mycroft.MycroftController.start();
            }

            Mycroft.StatusIndicator {
                id: si
                //visible: false
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: Kirigami.Units.largeSpacing
                }
                z: 999
            }

            Kirigami.Heading {
                id: inputQuery
                Kirigami.Theme.colorSet: mainView.Kirigami.Theme.colorSet
                anchors.right: si.left
                anchors.rightMargin: Kirigami.Units.largeSpacing
                anchors.verticalCenter: si.verticalCenter
                level: 3
                opacity: 0
                onTextChanged: {
                    opacity = 1;
                    utteranceTimer.restart();
                }
                Timer {
                    id: utteranceTimer
                    interval: 8000
                    onTriggered: {
                        inputQuery.text = "";
                        inputQuery.opacity = 0
                    }
                }
                Behavior on opacity {
                    OpacityAnimator {
                        duration: Kirigami.units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Connections {
                    target: Mycroft.MycroftController
                    onIntentRecevied: {
                        if(type == "recognizer_loop:utterance") {
                            inputQuery.text = data.utterances[0]
                        }
                    }
                }
            }
        }

        //Note: a custom control as ToolBar on Android has a funny color
        footer: Control {
            Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.Window
            visible: !hideTextInput
            height: hideTextInput ? 0 : implicitHeight
            implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
            contentItem: RowLayout {
                Item {
                    id: handleAnchor
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                }
                
                ToolButton {
                    id: backButton
                    Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.Window
                    Layout.preferredWidth: handleAnchor.width
                    Layout.fillHeight: true
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    enabled: !isAndroid && Kirigami.Settings.isMobile ? 1 : 0
                    icon.name: "go-previous"
                    
                    onClicked:  {
                        mainView.currentItem.backRequested()
                    }
                    visible: !isAndroid && Kirigami.Settings.isMobile ? 1 : 0
                }
                
                
                TextField {
                    id: qinput
                    Layout.fillWidth: true

                    placeholderText: "Ask Mycroft..."
                    onAccepted: {
                        Mycroft.MycroftController.sendText(qinput.text)
                    }
                    focus: false
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
                
                ToolButton {
                    id: micButton
                    Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.Window
                    Layout.preferredWidth: handleAnchor.width
                    Layout.fillHeight: true
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    icon.name: "audio-input-microphone"
                    
                    onClicked:  {
                        if(applicationSettings.usesRemoteSTT){
                            audioRecorder.open()
                        } else {
                            speechIntent.start()
                        }
                    }
                    visible: speechIntent.supported || applicationSettings.usesRemoteSTT
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
