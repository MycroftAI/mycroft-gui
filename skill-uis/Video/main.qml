import QtMultimedia 5.9
import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0

import "../components"

BasicDelegateBase {
    backgroundImage: "https://source.unsplash.com/random"
    
    property alias content: video.source

    Item { //maybe a flickable in case there's too much text instead of Eliding (Flickable delegate base?)
        anchors.fill: parent
        
        Video {
            id: video
            anchors.fill: parent
            source: modelData.video
            focus: true
            fillMode: VideoOutput.Stretch
            autoPlay: true
            Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
            Keys.onLeftPressed: video.seek(video.position - 5000)
            Keys.onRightPressed: video.seek(video.position + 5000)
            
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    playerBar.open()
                }
            }
            
            Drawer {
                id: playerBar
                edge: Qt.BottomEdge
                width: parent.width
                height: Kirigami.Units.gridUnit * 4
                dragMargin: 0
            
            background: Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "#00000000"
            }
            
            Row {
            spacing: 10
            anchors.fill: parent
            
            Rectangle {
                id: playButton
                width: Kirigami.Units.gridUnit * 2
                height: Kirigami.Units.gridUnit * 2
                color: Kirigami.Theme.backgroundColor
                border.width: 1
                border.color: Qt.lighter(Kirigami.Theme.textColor, 1.2);
                radius: 200

            Image {
                id: playIcon
                width: Kirigami.Units.gridUnit * 2
                height: Kirigami.Units.gridUnit * 2
                anchors.centerIn: parent
                source: video.playbackState === MediaPlayer.PlayingState ? "images/media-playback-pause.svg" : "images/media-playback-start.svg"
            }

            ColorOverlay {
                id: coverlayplay
                anchors.fill: playIcon
                source: playIcon
                color: Kirigami.Theme.textColor
            }

            MouseArea {
                id: mAreaPlayButton
                anchors.fill: parent
                onClicked: video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play()
                hoverEnabled: true

                onEntered: {
                    playButton.color = Kirigami.Theme.textColor
                    coverlayplay.color = Kirigami.Theme.backgroundColor
                    }
                onExited: {
                    playButton.color = Kirigami.Theme.backgroundColor
                    coverlayplay.color = Kirigami.Theme.textColor
                    }
                }
            }
            
                SeekControl {
                    width: parent.width - Kirigami.Units.gridUnit * 3
                    anchors.verticalCenter: playButton.verticalCenter
                    duration: video.duration
                    playPosition: video.position
                    onSeekPositionChanged: video.seek(seekPosition);
                }
            
                }
            }
            
            
        }
    }
}
