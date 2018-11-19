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
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

//FIXME: we probably want to wrap this in an Item or Control as we don't want to expose full StackView api
Item {
    id: root

    property Item initialItem: null
    onInitialItemChanged: {
        initialItem.parent = restFaceParent;
        initialItem.anchors.fill = restFaceParent;
    }


    property int rightPadding: 0
    property int topPadding: 0
    property int leftPadding: 0
    property int bottomPadding: 0

    readonly property Item currentItem: null

    //for delegates to access the view... eventually this could be come an attache dproperty
    function view() {
        return root;
    }

    function goBack() {
        
    }

    Component.onCompleted: {
        Mycroft.MycroftController.registerGui(root)
    }


    Connections {
        id: mycroftConnection
        target: Mycroft.MycroftController

        onSkillGuiCreated: {
            var swipeView = repeater.swipeViewForSkill(skillId);
            gui.parent = swipeView;
            for (var i = 0; i < swipeView.contentChildren.length; ++i) {
                swipeView.contentChildren[i];
            }
            swipeView.addItem(gui)
            swipeView.incrementCurrentIndex();
            restFaceSwipeView.currentIndex = 1;
        }

        onStopped: {
            return;
        }

        onSkillDataRecieved: {
            print(data)
        }

        onSpeakingChanged: {
            //starting the timeout of the delegate
        }
    }

    Controls.SwipeView {
        id: restFaceSwipeView
        anchors.fill: parent
        Item {
            id: restFaceParent
        }
        Controls.StackView {
            id: skillsStack
        }
    }
    Repeater {//TODO: the model will have models of gui instances, much simpler
        id: repeater
        function swipeViewForSkill(skillId) {
            var item;
            for (var i = 0; i < count; ++i) {
                item = itemAt(i);
                //TODO
                if (1||item.skillId == skillId) {
                    return item;
                }
            }
        }
        model: 1//Mycroft.MycroftController.activeSkills
        delegate: Controls.SwipeView {
            id: swipeView
            anchors.fill: parent
            property string skillId: model.display
            Component.onCompleted: skillsStack.push(swipeView)
        }
    }
}
