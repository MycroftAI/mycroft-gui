/*
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
import org.kde.kirigami 2.4 as Kirigami

/**
 * Takes a long text and breaks it down into pages that can be horizontally swiped
 */
Flickable {
    id: root

    /**
     * text: string
     * The text that should be displayed
     */
    property alias text: label.text

    /**
     * columns: int
     * How many colums the text has been paginated into
     */
    readonly property int columns: label.internalColumns

    /**
     * currentIndex: int
     * The currently visible page number (starting from 0)
     */
    property int currentIndex: 0

    /**
     * font: font
     * Font of the text control: note: this shoul normally never touched as
     * it should follow settings from the system
     */
    property alias font: label.font

    /**
     * horizontalAlignment: Enum
     * How the text is aligned, possible values are:
     * Text.AlignLeft, Text.AlignRight, Text.AlignHCenter and Text.AlignJustify.
     */
    property alias horizontalAlignment: label.horizontalAlignment

    /**
     * padding we want to have for the text
     */
    property int leftPadding: Kirigami.Units.largeSpacing
    property int topPadding: Kirigami.Units.largeSpacing
    property int rightPadding: Kirigami.Units.largeSpacing
    property int bottomPadding: Kirigami.Units.largeSpacing



    contentWidth: label.columnWidth * (label.internalColumns)
    contentHeight: height

    onWidthChanged: label.relayout()
    onHeightChanged: label.relayout()

    onMovementEnded: label.updateCurrentIndex()
    onFlickEnded: label.updateCurrentIndex()

    onCurrentIndexChanged: label.snap()

    NumberAnimation {
        id: slideAnim
        target: root
        property: "contentX"
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
    }

    Controls.Label {
        id: label
        y: root.topPadding
        width: root.width - root.leftPadding - root.rightPadding
        height: root.height - root.topPadding - root.bottomPadding - pageIndicator.height
        // All the properties in label rather than on root item are for internal use 
        // only and should never be accessed by the QML code external of this component
        readonly property int columnWidth: root.width
        property int internalColumns: 1
        property real lastLineY: 0
        property real lastLineHeight: 0

        font.pointSize: -1
        font.pixelSize: Math.min(root.width, root.height) / 100 * 12

        function updateCurrentIndex() {
            root.currentIndex = Math.round(root.contentX / columnWidth);
            snap();
        }

        function snap() {
            slideAnim.from = root.contentX;
            slideAnim.to = root.currentIndex * columnWidth;
            slideAnim.restart();
        }

        function relayout() {
            label.internalColumns = 1;
            lastLineY = 0;
            lastLineHeight = 0;
            forceLayout();
        }

        wrapMode: Text.WordWrap

        onLineLaidOut: {
            if ( width <= 0 || height <= 0) {
                return;
            }
            if (line.y == 0) {
                label.internalColumns = 1;
                lastLineY = 0;
                lastLineHeight = 0;
            }

            if (lastLineY + lastLineHeight + line.height > height) {
                ++label.internalColumns;
                line.y = 0;
            } else {
                line.y = lastLineY + lastLineHeight;
            }

            line.x = columnWidth * (label.internalColumns - 1) + root.leftPadding;

            lastLineY = line.y;
            lastLineHeight = line.height;
        }
    }

    children: [
        Controls.PageIndicator {
            id: pageIndicator
            visible: root.columns > 1
            z: 999
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: Kirigami.Units.largeSpacing
            }
            count: root.columns
            currentIndex: root.currentIndex
        }
    ]
}
