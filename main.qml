import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Mycroft 1.0

Rectangle {
    visible: true
    width: 640
    height: 480

    Mycroft {
        id: mycroft
        onSkillDataRecieved: {
            text.text = data["utterance"];
        }
    }

    Component.onCompleted: {
        mycroft.open("ws://0.0.0.0:8181/core");
    }

    ColumnLayout {
        TextField {
            id: qinput
            onAccepted: {
                mycroft.sendText(qinput.text)
            }
        }
    }

    Text {
        id: text
    }
}
