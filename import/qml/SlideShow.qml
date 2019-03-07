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
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

/**
 * Contains an slideshow object that can autoplay each slide and loop
 * This can be used inside any mycroft delegate like in the following example.
 *
 * @code
 *  Mycroft.Delegate {
 *      ...
 *      Mycroft.SlideShow {
 *              id: root model: sessionData.exampleModel // model with slideshow data
 *              anchors.fill: parent
 *              interval: 5000 // time to switch between slides 
 *              running: true // can be set to false if one wants to swipe manually 
 *              delegate: Item {...}
 *              loop: true // can be set to play through continously or just once
 *      }
 *  }
 * @endcode
 */

Item {
    id: root
    focus: true
    
    //Listview Model
    property alias model: slideShowView.model
    
    //Listview Delegate
    property alias delegate: slideShowView.delegate
    
    //Slideshow Timer Control
    property alias interval: slideShowTimer.interval
    
    //Slideshow Timer Running
    property alias running: slideShowTimer.running
    
    //Slideshow Timer Loop
    property alias loop: slideShowTimer.repeat
    
    Timer {
        id: slideShowTimer
        interval: 5000
        running: false
        repeat: true
        onTriggered: {
            var getCount = slideShowView.count
            if(slideShowView.currentIndex !== getCount){
                slideShowView.currentIndex = slideShowView.currentIndex+1;
            } else{
                slideShowView.currentIndex = 0
            }
        }
    }
    
    ColumnLayout { 
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing
        
        ListView {
            id: slideShowView
            layoutDirection: Qt.LeftToRight
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: root.height - slideshowIndicator.height
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem;
            flickableDirection: Flickable.AutoFlickDirection
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true
            spacing: Kirigami.Units.largeSpacing
            clip: true
            
            onFlickEnded: {
                slideShowTimer.restart()
            }
        }
        
        Controls.PageIndicator {
            id: slideshowIndicator
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            currentIndex: slideShowView.currentIndex
            count: slideShowView.count        
        }
    }
    
    Keys.onLeftPressed: {
            if (slideShowView.currentIndex > 0 ) {
                slideShowView.currentIndex = slideShowView.currentIndex-1
            }
            
            if (slideShowView.currentIndex == 0 ) {
                slideShowView.currentIndex = slideShowView.count
            }
            slideShowTimer.restart()
    }

    Keys.onRightPressed: {
        if (slideShowView.currentIndex < slideShowView.count) {
            slideShowView.currentIndex = Math.min(slideShowView.currentIndex+1, slideShowView.count)
        } 
        
        if(slideShowView.currentIndex == slideShowView.count) {
            slideShowView.currentIndex = 0
        }
        slideShowTimer.restart()
    }
}
