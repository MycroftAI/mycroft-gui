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
        }
        Item {
            Repeater {
                model: activeSkills
                delegate: Controls.SwipeView {
                    id: swipeView
                    anchors.fill: parent
                    //assume the index 0 is the one most recently used, so the one that should be shown
                    visible: index == 0
                    Repeater {
                        model: model.delegates
                        delegate: Controls.Control {
                            contentItem: model.delegateUi
                        }
                    }
                }
            }
        }
    }
}
