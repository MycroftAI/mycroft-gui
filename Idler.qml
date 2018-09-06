import QtQuick 2.4
import QtQuick.Controls 2.4
import Mycroft 1.0 as Mycroft

Rectangle {
    color: "black"

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
}
