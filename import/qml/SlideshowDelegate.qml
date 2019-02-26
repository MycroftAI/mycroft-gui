/*
 * Copyright 2019 by Aditya Mehra <aix.m@outlook.com>
 * Copyright 2019 by Marco Martin <mart@kde.org>
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
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

Delegate {
    id: control
    
    //Listview Model
    property alias model: slideShowView.model
    
    //Listview Delegate
    property alias delegate: slideShowView.delegate
    
    //Slideshow Timer Control
    property alias interval: slideShowTimer.interval
    
    //Slideshow Timer Running
    property alias running: slideShowTimer.running
    
    Timer {
        id: slideShowTimer
        interval: 5000
        running: false
        repeat: true
        onTriggered: {
            var getCount = slideShowView.count
            if(slideShowView.currentIndex !== getCount){
                slideShowView.currentIndex = slideShowView.currentIndex+1;
            }
            else{
                slideShowView.currentIndex = 0
            }
        }
    }

    contentItemAutoHeight: false
    contentItem: ListView {
        id: slideShowView
        anchors.top:  parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        layoutDirection: Qt.LeftToRight
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem;
        flickDeceleration: 500
        focus: true
        flickableDirection: Flickable.AutoFlickDirection
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        spacing: Kirigami.Units.largeSpacing

        Keys.onLeftPressed: {
            if (currentIndex > 0 )
                currentIndex = currentIndex-1
            slideShowTimer.restart()
        }

        Keys.onRightPressed: {
            if (currentIndex < count)
                currentIndex = currentIndex+1
            slideShowTimer.restart()
        }

        onFlickEnded: {
            slideShowTimer.restart()
        }
    }
}
 
