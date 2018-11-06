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
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

//FIXME: we probably want to wrap this in an Item or Control as we don't want to expose full StackView api
Item {
    id: root

    property Item initialItem: null
    onInitialItemChanged: {
        initialItem. parent = root
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
            swipeView.incrementCurrentIndex()
        }

        onStopped: {
            return;
        }

        onSkillDataRecieved: {
            print(data)
        }

        onSpeakingChanged: {
            
        }
    }

    Repeater {
        id: repeater
        function swipeViewForSkill(skillId) {
            var item;
            for (var i = 0; i < count; ++i) {
                item = itemAt(i);
                print("FGGGGGG"+item+"/"+item.skillId +".."+ skillId )
                //TODO
                if (1||item.skillId == skillId) {
                    return item;
                }
            }
        }
        model: Mycroft.MycroftController.activeSkills
        delegate: Controls.SwipeView {
            id: swipeView
            anchors.fill: parent
            property string skillId: model.display
        }
    }
}
