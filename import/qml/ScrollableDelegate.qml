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
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami

DelegateBase {
    id: control

    //this to make all items children of the scrollview item so everything will have paddings automagically
    default property alias data: main.contentData

    leftPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (Controls.StackView.view ? Controls.StackView.view.leftPadding : 0)
    topPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (Controls.StackView.view ? Controls.StackView.view.topPadding : 0)
    rightPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (Controls.StackView.view ? Controls.StackView.view.rightPadding : 0)
    bottomPadding: (main.mainItem.hasOwnProperty("contentHeight") ? 0 : Kirigami.Units.largeSpacing) + (Controls.StackView.view ? Controls.StackView.view.bottomPadding : 0)

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
