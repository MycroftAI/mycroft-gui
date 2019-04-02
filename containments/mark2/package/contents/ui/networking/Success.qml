/*
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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

import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.lottie 1.0

Item {
    id: successView
    anchors.fill: parent
    
    ColumnLayout {
        anchors.fill: parent
        LottieAnimation {
            id: successAnimation
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: Qt.resolvedUrl("Animations/success.json")
            loops: 0
            fillMode: Image.PreserveAspectFit
            running: true
            
            onRunningChanged: {
                if(successAnimation.status == 1){
                    networkingLoader.source = "../networking/SelectNetwork.qml"
                }
            }
        }    
    }
}
 
