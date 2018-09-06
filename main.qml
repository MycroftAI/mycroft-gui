import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft


Kirigami.AbstractApplicationWindow {
    visible: true

    color: "grey"
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Component.onCompleted: {
        Mycroft.MycroftController.open("ws://0.0.0.0:8181/core");
    }

    Item {
        width: deviceWidth || parent.width
        height: deviceHeight || parent.height
        anchors.centerIn: parent
        ColumnLayout {
            anchors.fill: parent
            TextField {
                Layout.fillWidth: true
                id: qinput
                onAccepted: {
                    Mycroft.MycroftController.sendText(qinput.text)
                }
                visible: !hideTextInput
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
}


