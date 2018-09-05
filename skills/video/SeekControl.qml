import QtQuick 2.4
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: seekControl
    property int duration: 0
    property int playPosition: 0
    property int seekPosition: 0
    property bool enabled: true
    property bool seeking: false

    Rectangle {
        id: progressBar
        anchors { left: parent.left; bottom: parent.verticalCenter }
        width: seekControl.duration == 0 ? 0 : parent.width * seekControl.playPosition / seekControl.duration
        height: 4
        color: "white"
        opacity: 0.7
    }

    Text {
        anchors { left: parent.left; top: parent.verticalCenter; bottom: parent.bottom; topMargin: Units.smallSpacing}
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: "white"
        text: formatTime(playPosition)
    }

    Text {
        anchors { right: parent.right; top: parent.verticalCenter; bottom: parent.bottom; topMargin: Units.smallSpacing}
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        color: "white"
        text: formatTime(duration)
    }

    Rectangle {
        id: progressHandle
        height: progressBar.height
        width: progressBar.height / 2
        color: "white"
        opacity: 0.5
        anchors.verticalCenter: progressBar.verticalCenter
        x: seekControl.duration == 0 ? 0 : seekControl.playPosition / seekControl.duration * parent.width

        MouseArea {
            id: mouseArea
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
            height: parent.height
            width: parent.height * 2
            enabled: seekControl.enabled
            drag {
                target: progressHandle
                axis: Drag.XAxis
                minimumX: 0
                maximumX: background.width
            }
            onPressed: {
                seekControl.seeking = true;
            }
            onCanceled: {
                seekControl.seekPosition = progressHandle.x * seekControl.duration / background.width
                seekControl.seeking = false
            }
            onReleased: {
                seekControl.seekPosition = progressHandle.x * seekControl.duration / background.width
                seekControl.seeking = false
                mouse.accepted = true
            }
        }
    }

    Timer { // Update position also while user is dragging the progress handle
        id: seekTimer
        repeat: true
        interval: 300
        running: seekControl.seeking
        onTriggered: {
            seekControl.seekPosition = progressHandle.x*seekControl.duration / parent.width
        }
    }

    function formatTime(timeInMs) {
        if (!timeInMs || timeInMs <= 0) return "0:00"
        var seconds = timeInMs / 1000;
        var minutes = Math.floor(seconds / 60)
        seconds = Math.floor(seconds % 60)
        if (seconds < 10) seconds = "0" + seconds;
        return minutes + ":" + seconds
    }
}
