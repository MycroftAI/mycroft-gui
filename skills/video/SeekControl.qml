import QtQuick 2.4
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as Controls
import QtQuick.Templates 2.2 as Templates
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: seekControl
    property bool opened: false
    property int duration: 0
    property int playPosition: 0
    property int seekPosition: 0
    property bool enabled: true
    property bool seeking: false
    property Video videoControl

    clip: true
    implicitHeight: mainLayout.implicitHeight + Kirigami.Units.largeSpacing * 2
    opacity: opened

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutCubic
        }
    }

    onOpenedChanged: {
        if (opened) {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: seekControl.opened = false;
    }
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
        }
        height: parent.height
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.6)
        y: opened ? 0 : parent.height

        Behavior on y {
            YAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        RowLayout {
            id: mainLayout
            anchors {
                fill: parent
                margins: Kirigami.Units.largeSpacing
            }
            Templates.ToolButton {
                id: button
                hoverEnabled: true
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: implicitWidth
                Kirigami.Theme.inherit: true
                onClicked: {
                    video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play();
                    hideTimer.restart();
                }
                //text: "bah"
                //FIXME: do we really want those completely custom controls? as soon as plasma style can follow correctly colorSet it should use that
                contentItem: Rectangle {
                    radius: width
                    color: button.hovered ? Kirigami.Theme.textColor : Kirigami.Theme.backgroundColor
                    Image {
                        id: playIcon
                        anchors.fill: parent
                        source: videoControl.playbackState === MediaPlayer.PlayingState ? "images/media-playback-pause.svg" : "images/media-playback-start.svg"
                    }

                    ColorOverlay {
                        id: coverlayplay
                        anchors.fill: playIcon
                        source: playIcon
                        color: button.hovered ? Kirigami.Theme.backgroundColor : Kirigami.Theme.textColor
                    }
                }
            }
            Templates.Slider {
                id: slider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                implicitHeight: Kirigami.Units.gridUnit
                value: seekControl.playPosition
                from: 0
                to: seekControl.duration
                onMoved: {
                    seekControl.seekPosition = value;
                    hideTimer.restart();
                }
                handle: Rectangle {
                    x: slider.position * (parent.width - width)
                    implicitWidth: Kirigami.Units.gridUnit
                    implicitHeight: implicitWidth
                    radius: width
                }
                background: Item {
                    Rectangle {
                        id: groove
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                        }
                        radius: height
                        height: Math.round(Kirigami.Units.gridUnit/3)
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.3)
                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            radius: height
                            color: Kirigami.Theme.textColor
                            width: slider.position * (parent.width - slider.handle.width/2) + slider.handle.width/2
                        }
                    }

                    Controls.Label {
                        anchors {
                            left: parent.left
                            top: groove.bottom
                            topMargin: Kirigami.Units.smallSpacing
                        }
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: formatTime(playPosition)
                        color: "white"
                    }

                    Controls.Label {
                        anchors {
                            right: parent.right
                            top: groove.bottom
                            topMargin: Kirigami.Units.smallSpacing
                        }
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        text: formatTime(duration)
                    }
                }
            }
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
