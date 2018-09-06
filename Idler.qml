import QtQuick 2.4
import QtQuick.Controls 2.4
import Mycroft 1.0 as Mycroft

/* Class used to simulate the homescreen in cases where we're not using minimal shell
 */

Item {
    //I was asked to have a button. I have no idea why one wouldn't just connect on startup...
    Button {
        anchors.centerIn: parent
        text: "start"
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Closed
        onClicked: Mycroft.MycroftController.start();
    }

    BusyIndicator {
        anchors.centerIn: parent
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Connecting
    }

    ClockFace {
        id: face
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.7
        height: Math.min(parent.width, parent.height) * 0.7
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Open
        showSecondsHand: true
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: face.time = new Date();
        }
    }
}
