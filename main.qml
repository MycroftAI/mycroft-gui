import QtQuick 2.9
import QtQuick.Controls 2.2
import WSocket 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Scroll")

    Component.onCompleted: {
        socket.open("ws://0.0.0.0:8181/core")
    }

    WSocket {
        id: socket
          onMessageReceived: {
              console.log(message)
        }
        onStatusChanged: {

      }
    }

    ScrollView {
        anchors.fill: parent

        Button {
        anchors.fill: parent
        text: "CLICK"
        onClicked: {
            }
        }
    }

   header: TextField{
       id: qinput
       width: parent.width
       height: 30
       onAccepted: {
           var socketmessage = {};
           socketmessage.type = "recognizer_loop:utterance";
           socketmessage.data = {};
           socketmessage.data.utterances = [qinput.text];
           socket.onSendMessage(JSON.stringify(socketmessage));
       }
    }
}
