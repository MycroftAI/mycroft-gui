import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Loader {
    id: networkingLoader
    property var securityType
    property var connectionName
    property var devicePath
    property var specificPath
    
    z: 1000
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        margins: Kirigami.Units.gridUnit
    }

    Component.onCompleted: {
        networkingLoader.source = "../networking/SelectNetwork.qml"
    }
}
