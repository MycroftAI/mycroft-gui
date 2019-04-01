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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft
import org.kde.plasma.private.volume 0.1 as PA

Delegate {
    id: delegate
    iconSource: toggled ? "audio-volume-high" : "audio-volume-muted"
    text: toggled ? i18n("Unmute") : i18n("Mute")

    onToggledChanged: paSinkModel.preferredSink.muted = toggled

    PA.SinkModel {
        id: paSinkModel
    }
    onClicked: {
        Mycroft.MycroftController.sendRequest(delegate.toggled ? "mycroft.mic.unmute" : "mycroft.mic.mute", {});
    }
    Component.onCompleted: {
        Mycroft.MycroftController.sendRequest("mycroft.mic.get_status", {});
    }
    Connections {
        target: Mycroft.MycroftController
        onSocketStatusChanged: {
            if (Mycroft.MycroftController.status == Mycroft.MycroftController.Open) {
                Mycroft.MycroftController.sendRequest("mycroft.mic.get_status", {});
            }
        }
        onSkillDataRecieved: {
            if (type == "mycroft.mic.get_status.response") {
                delegate.toggled = data.muted;

            } else if (type =="mycroft.mic.mute" || type =="mycroft.mic.unmute") {
                Mycroft.MycroftController.sendRequest("mycroft.mic.get_status", {});
            }
        }
    }
}

