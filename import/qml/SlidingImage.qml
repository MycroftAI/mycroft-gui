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
import org.kde.kirigami 2.4 as Kirigami

/**
 * Contains an image that will slowly scroll in order to be shown completely
 * This is supoposed to be used as background item for a skill,
 * like in the following example.
 *
 * @code
 *  Mycroft.Delegate {
 *      background: Mycroft.SlidingImage {
 *          source: "foo.jpg"
 *      }
 *  }
 * @endcode
 */
Item {
    id: root

    /**
     * running: bool
     * If true the sliding animation is active
     */
    property bool running: true

    /**
     * source: url
     * source for the image
     */
    property alias source: image.source

    /**
     * speed: real
     * Animation speed in Kirigami.Units.gridUnit / second
     */
    property real speed: 1

    clip: true
    Component.onCompleted: image.updateAnims()
    onWidthChanged: image.updateAnims()
    onHeightChanged: image.updateAnims()
    onRunningChanged: image.updateAnims()

    Image {
        id: image
        fillMode: Image.PreserveAspectFit

        readonly property bool horizontal: sourceSize.width / sourceSize.height > root.width / root.height
        //Transforms the speed into duration
        readonly property real duration: horizontal
            ? ((image.width - root.width) / (root.speed * Kirigami.Units.gridUnit)) * 1000
            : ((image.height - root.height) / (root.speed * Kirigami.Units.gridUnit)) * 1000

        width: horizontal
            ? root.height * (sourceSize.width / sourceSize.height)
            : root.width
        height: horizontal
            ? root.height
            : root.width * (sourceSize.height / sourceSize.width)
        onWidthChanged: updateAnims()
        onHeightChanged: updateAnims()

        function updateAnims() {
            xAnim.running = false;
            yAnim.running = false;
            if (!root.running) {
                return;
            }
            xAnim.running = image.width > root.width;
            yAnim.running = image.height > root.height;
        }
    }

    SequentialAnimation {
        id: xAnim
        loops: Animation.Infinite
        XAnimator {
            target: image
            from: 0
            to: root.width - image.width
            duration: image.duration
            easing.type: Easing.InOutQuad
        }
        XAnimator {
            target: image
            from: root.width - image.width
            to: 0
            duration: image.duration
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: yAnim
        loops: Animation.Infinite
        YAnimator {
            target: image
            from: 0
            to: root.height - image.height
            duration: image.duration
            easing.type: Easing.InOutQuad
        }
        YAnimator {
            target: image
            from: root.height - image.height
            to: 0
            duration: image.duration
            easing.type: Easing.InOutQuad
        }
    }
}
