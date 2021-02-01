import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

Item {
    id: root
    anchors.fill: parent
    property alias record: audrectimer.running

    Timer {
        id: audrectimer
        interval: 10000
        running: false
        onRunningChanged: {
            if(running){
                Mycroft.AudioRec.recordTStart()
                numAnim.start()
            } else {
                Mycroft.AudioRec.recordTStop()
                numAnim.stop()
            }
        }
    }

    function sendAudioClip() {
        Mycroft.AudioRec.returnStream()
    }

    Connections {
        target: Mycroft.AudioRec

        onMicAudioLevelChanged: {
            animatedCircle.width = Kirigami.Units.iconSizes.large + (Kirigami.Units.iconSizes.smallMedium * micLevel)
        }

        onRecordTStatus: {
            switch(recStatus){
            case "Completed":
                console.log("In Completed")
                Mycroft.AudioRec.readStream()
                sendAudioClip()
                audioRecorder.close()
                break;
            case "Error":
                console.log("inError")
                break;
            }
        }
    }

    ColumnLayout {
        id: closebar
        anchors.fill: parent
        spacing: 0

        Kirigami.Heading {
            id: lbl1
            text: "Listening"
            Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.View
            level: 2
            font.bold: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Kirigami.Theme.disabledTextColor
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: animatedCircle
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                radius: 1000
                color: Qt.rgba(Kirigami.Theme.linkColor.r, Kirigami.Theme.linkColor.g, Kirigami.Theme.linkColor.b, 0.7)

                Image {
                    source: "images/microphone.svg"
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width

                }
            }
        }

        Kirigami.Heading {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.preferredHeight: paintedHeight
            Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.View
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            level: 3
            horizontalAlignment: Text.AlignHCenter
            text: "Say something to Mycroft"
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.smallSpacing * 0.15

            ProgressBar {
                id: bar
                to: 100
                from: 0
                anchors.fill: parent

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: Kirigami.Theme.disabledTextColor
                }

                contentItem: Item {
                    implicitWidth: parent.width
                    implicitHeight: parent.height

                    Rectangle {
                        width: bar.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Kirigami.Theme.linkColor }
                            GradientStop { position: 1.0; color: Kirigami.Theme.linkColor }
                        }
                    }
                }

                NumberAnimation {
                    id: numAnim
                    target: bar
                    property: "value"
                    from: 0
                    to: 100
                    duration: 10000
                }
            }
        }

        Rectangle {
            Kirigami.Theme.colorSet: nightSwitch.checked ? Kirigami.Theme.Complementary : Kirigami.Theme.View
            color: Kirigami.Theme.hoverColor
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

            Kirigami.Heading {
                level: 2
                text: "Close"
                anchors.centerIn: parent
                anchors.margins: Kirigami.Units.largeSpacing
            }

            MouseArea {
                anchors.fill: parent
                onClicked: audioRecorder.close()
            }
        }
    }
}

