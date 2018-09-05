import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Rectangle {
    visible: true
    width: 640
    height: 480
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Component.onCompleted: {
        Mycroft.MycroftController.open("ws://0.0.0.0:8181/core");
    }

    ColumnLayout {
        anchors.fill: parent
        TextField {
            Layout.fillWidth: true
            id: qinput
            onAccepted: {
                Mycroft.MycroftController.sendText(qinput.text)
            }
        }
        MainView {
            id: mainView
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
    Mycroft.StatusIndicator {
        id: si
        visible: true

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.largeSpacing
        }
    }
}


