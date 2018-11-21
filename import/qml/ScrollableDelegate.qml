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
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

//TODO: this muct become a Delegate subclass
Delegate {
    id: control

    //this to make all items children of the scrollview item so everything will have paddings automagically
    default property alias data: main.contentData

    readonly property bool userInteracting: main.contentItem.hasOwnProperty("moving") && main.contentItem.moving

    leftPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (typeof view  !== "undefined" && view() ? view().leftPadding : 0)
    topPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (typeof view  !== "undefined" && view() ? view().topPadding : 0)
    rightPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (typeof view  !== "undefined" && view() ? view().rightPadding : 0)
    bottomPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (typeof view  !== "undefined" && view() ? view().bottomPadding : 0)

    Component.onCompleted: main.contentItem.clip = false
    //clip the delegate and not the scrollview because we do want items to bleed over margins
    clip: true
    contentItem: Controls.ScrollView {
        id: main
        contentWidth: width
        clip: false
        //if mainItem is == contentItem then the main item is a flickable, otherwise is auto created internally
        property Item mainItem: contentChildren[contentChildren.length-1]

        contentHeight: mainItem.hasOwnProperty("contentHeight") ? mainItem.contentHeight : mainItem.height
    }
}
