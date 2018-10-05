/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Controls 2.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

//FIXME: we probably want to wrap this in an Item or Control as we don't want to expose full StackView api
StackView {
    id: mainStack

    function goBack() {
        if (mainStack.depth == 1) {
            return;
        }

        mainStack.pop();
        mycroftConnection.metadataType.pop();
        popTimer.running = false;
        countdownAnim.running = false;
    }

    Component.onCompleted: {
        if (!mainStack.initialItem) {
            mainStack.initialItem = initialPlaceHolder;
        }
    }

    //this is to make the class work wether the user specifies an initialItem or not 
    Item {
        id: initialPlaceHolder
    }

    Mycroft.SkillLoader {
        id: skillLoader
    }

    Connections {
        id: mycroftConnection
        property var metadataType: []
        target: Mycroft.MycroftController

        function openSkillUi(type, data) {
            var _url = skillLoader.uiForMetadataType(type);
            if (!_url) {
                return;
            }

            if (mycroftConnection.metadataType[mycroftConnection.metadataType.length - 1] == type) {
                var key;
                for (key in data) {
                    if (mainStack.currentItem.hasOwnProperty(key)) {
                        mainStack.currentItem[key] = data[key];
                    }
                }
            } else {
                mycroftConnection.metadataType.push(type);
                mainStack.push(_url, data);
            }

            popTimer.running = false;
            countdownAnim.running = false;
        }

        //These few lines are a cludge to make existing skills work that don't have metadata (yet)
        onFallbackTextRecieved: {
            console.log("Fallback", skill);
            var regex = /(.*)Skill*/;
            var found = skill.match(regex);
            if (found.length > 1) {
                openSkillUi(found[1].toLowerCase(), data);
            }
        }

        onStopped: {
            //explictly unset
            if (mainStack.depth > 1) {
                popTimer.running = false;
                countdownAnim.running = false;
                mainStack.pop();
                mycroftConnection.metadataType.pop();
            }
            return;
        }

        onSkillDataRecieved: {
            openSkillUi(data["type"], data);
        }

        onSpeakingChanged: {
            if (!Mycroft.MycroftController.speaking) {
                if (mainStack.depth > 1 && (!mainStack.currentItem.hasOwnProperty("graceTime") || (mainStack.currentItem.graceTime != Infinity && mainStack.currentItem.graceTime > 0))) {
                    popTimer.restart();
                    countdownAnim.restart();
                }
            }
        }
    }
    Connections {
        target: mainStack.currentItem
        onBackRequested: mainStack.goBack();
        onUserInteractingChanged: {
            if (mainStack.currentItem.userInteracting) {
                popTimer.running = false;
                countdownAnim.running = false;
            } else if (!Mycroft.MycroftController.speaking && (!mainStack.currentItem.hasOwnProperty("graceTime") || (mainStack.currentItem.graceTime != Infinity && mainStack.currentItem.graceTime > 0))) {
                popTimer.restart();
                countdownAnim.restart();
            }
        }
    }

    Timer {
        id: popTimer
        interval: mainStack.currentItem.hasOwnProperty("graceTime") ? mainStack.currentItem.graceTime : 0
        onTriggered: {
            if (mainStack.depth > 1) {
                mainStack.pop(get(0));
                mycroftConnection.metadataType = [];
            }
        }
    }

    Rectangle {
        id: countdownScrollBar
        z: 999
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        height: Kirigami.Units.smallSpacing
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        color: Kirigami.Theme.textColor
        width: 0
        opacity: countdownAnim.running ? 0.6 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }

        PropertyAnimation {
            id: countdownAnim
            target: countdownScrollBar
            property: "width"
            from: parent.width
            to: 0
            duration: popTimer.interval
        }
    }
}
