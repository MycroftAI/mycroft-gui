/*
 *   Copyright 2018 Marco Martin <notmart@gmail.com>
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

