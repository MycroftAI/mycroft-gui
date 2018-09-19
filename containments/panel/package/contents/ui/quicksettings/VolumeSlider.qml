/*
 *   Copyright 2018 Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <<davidedmundson@kde.org>>
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

import QtQuick 2.9
import Mycroft 1.0 as Mycroft
import org.kde.plasma.private.volume 0.1 as PA

SliderBase {
    leftIconSource: "audio-volume-low"
    rightIconSource: "audio-volume-high"

    slider.from: PA.PulseAudio.MinimalVolume
    slider.to: PA.PulseAudio.MaximalVolume

    slider.value: paSinkModel.preferredSink ? paSinkModel.preferredSink.volume : PA.PulseAudio.MinimalVolume
    slider.onMoved: paSinkModel.preferredSink.volume = slider.value

    PA.SinkModel {
        id: paSinkModel
    }

    //TODO: no way to query programmatically the volume from mycroft, especially without making it speak
    Connections {
        target: Mycroft.MycroftController
        onSocketStatusChanged: {
            if (Mycroft.MycroftController.status == Mycroft.MycroftController.Open) {
                //Mycroft.MycroftController.sendRequest("mycroft.volume.query", {});
            }
        }
        onSkillDataRecieved: {
            for (var i in data) {
                print(i+ ": "+data[i])
            }
            //TODO
            if (type == "mycroft.volume") {
                
            }
        }
    }
}
