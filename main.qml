import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Mycroft 1.0
import org.kde.kirigami 2.4 as Kirigami

Rectangle {
    visible: true
    width: 640
    height: 480
//     Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Mycroft {
        id: mycroft
    }

    Component.onCompleted: {
        mycroft.open("ws://0.0.0.0:8181/core");
    }

    ColumnLayout {
        anchors.fill: parent
        TextField {
            Layout.fillWidth: true
            id: qinput
            onAccepted: {
                mycroft.sendText(qinput.text)
            }
        }
        MainView {
            id: mainView
            mycroft: mycroft
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
    StatusIndicator {
        id: si
        visible: true
        mycroftController: mycroft

        onStateChanged: {
            console.log(state);
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.largeSpacing
        }
    }
}


