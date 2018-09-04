import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import "../components"

BasicDelegateBase {
    backgroundImage: "/opt/kde5/share/wallpapers/Kite/contents/images/1920x1200.jpg"

    property alias title: title.text
    property alias content: content.text

    ColumnLayout { //maybe a flickable in case there's too much text instead of Eliding (Flickable delegate base?)
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        Item {
            Layout.fillHeight: true
        }
        Kirigami.Heading {
            id: title
            Layout.fillWidth: true
            level: 1
            text: modelData.title
            wrapMode: Text.WordWrap
            visible: text.length > 0
        }
        Kirigami.Label {
            id: content
            Layout.fillWidth: true
            text: modelData.text
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: "#EEE"
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
