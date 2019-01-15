/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
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
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import org.kde.kirigami 2.4 as Kirigami

Label {
    id: root

    Layout.alignment: Qt.AlignCenter
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    //font.capitalization: Font.AllUppercase

    //TODO: to remove, all of that should end up in the device system setup
    font.family: "Noto Sans Display"

    color: "white"
    //HACK: needs a better way to fit its box
    //scale: 1.3
    topPadding: -height/5
    bottomPadding: -height/5
    fontSizeMode: Text.Fit;
    TextMetrics {
        id: metrics
        font {
            capitalization: root.font.capitalization
            family: root.font.family
            italic: root.font.italic
            styleName: root.font.styleName
            letterSpacing: root.font.letterSpacing
            strikeout: root.font.strikeout
            underline: root.font.underline
            weight: root.font.weight
            wordSpacing: root.font.wordSpacing
        }
        text: root.text
    }

    Layout.preferredWidth: paintedWidth
    Layout.preferredHeight: paintedHeight
    font.pixelSize: height

    /*onHeightChanged: {print(height)
        metrics.font.pixelSize = height*1.2;
        while ((metrics.tightBoundingRect.width > width || metrics.tightBoundingRect.height > height) && metrics.font.pixelSize > 8) {
            --metrics.font.pixelSize;
        }
        font.pixelSize = metrics.font.pixelSize
    }
    onWidthChanged: heightChanged();
*/

    renderType: height > 40
        ? Text.QtRendering
        : (Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering)
}
