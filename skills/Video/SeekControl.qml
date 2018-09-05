import QtQuick 2.4

Item {
    id: seekControl
    height: Math.min(parent.width, parent.height) / 20
    property int duration: 0
    property int playPosition: 0
    property int seekPosition: 0
    property bool enabled: true
    property bool seeking: false

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: 0.3
        radius: parent.height / 15
    }

    Rectangle {
        id: progressBar
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: seekControl.duration == 0 ? 0 : background.width * seekControl.playPosition / seekControl.duration
        color: "white"
        opacity: 0.7
    }

    Text {
        width: 90
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; leftMargin: 10 }
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: "white"
        smooth: true
        text: formatTime(playPosition)
    }

    Text {
        width: 90
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom; rightMargin: 10 }
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        color: "white"
        smooth: true
        text: formatTime(duration)
    }

    Rectangle {
        id: progressHandle
        height: parent.height
        width: parent.height / 2
        color: "white"
        opacity: 0.5
        anchors.verticalCenter: progressBar.verticalCenter
        x: seekControl.duration == 0 ? 0 : seekControl.playPosition / seekControl.duration * background.width

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
            seekControl.seekPosition = progressHandle.x*seekControl.duration / background.width
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
