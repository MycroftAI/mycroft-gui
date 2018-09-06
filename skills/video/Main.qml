import QtMultimedia 5.9
import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0

import Mycroft 1.0 as Mycroft

Rectangle {

    property alias video: video.source
    property alias status: video.currentStatus

    color: "black"
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Video {
        id: video
        anchors.fill: parent
        focus: true
        autoPlay: true
        Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
        Keys.onLeftPressed: video.seek(video.position - 5000)
        Keys.onRightPressed: video.seek(video.position + 5000)
        property var currentStatus

        onCurrentStatusChanged: {
            switch(currentStatus){
                case "stop":
                    video.stop();
                    break;
                case "pause":
                    video.pause()
                    break;
                case "resume":
                    video.play()
                    break;
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: seekControl.opened = !seekControl.opened
        }
        SeekControl {
            id: seekControl
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            videoControl: video
            duration: video.duration
            playPosition: video.position
            onSeekPositionChanged: video.seek(seekPosition);
        }
    }
}
