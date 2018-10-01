import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Kirigami.ScrollablePage {
    title: "Settings"
    objectName: "Settings"
    

    ColumnLayout {
        id: settingsLayout
        anchors.fill: parent
        
        Controls.Label {
            id: websocketLabel 
            text: "Websocket Address"
        }
        
        Controls.TextField {
            id: webSocketAddressField
            Layout.fillWidth: true
            
            Component.onCompleted:{
                webSocketAddressField.text = Mycroft.GlobalSettings.webSocketAddress
            }
        }
        
        Controls.Button{
            id: applySettings
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            text: "Apply"
            
            onClicked:{ 
                Mycroft.GlobalSettings.webSocketAddress = webSocketAddressField.text
                Mycroft.MycroftController.reconnect()
            }
        }
    }
}
