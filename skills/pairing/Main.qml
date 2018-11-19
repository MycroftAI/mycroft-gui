/*
 * Copyright 2018 Marco Martin <mart@kde.org>
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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

import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    backgroundHorizontalAlignment: Image.AlignLeft
    property alias code: content.text
    property alias instructions: instruction.text
    backgroundDim: 0.9
    graceTime: 120000

    ColumnLayout { //maybe a flickable in case there's too much text instead of Eliding (Flickable delegate base?)
        anchors {
            fill: parent
        }
        Kirigami.Heading {
            id: instruction
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            visible: !content.visible
        }
        Kirigami.Heading {
            id: content
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            visible: text.length > 0
        }
        
        Loader {
            id: webViewLoader
            source: "WebViewLoader.qml"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
