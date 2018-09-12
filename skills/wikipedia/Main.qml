import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    property alias title: title.text
    property alias image: img.source
    property alias content: content.text

    backgroundImage: img.source

    Flickable {
        anchors.fill: parent
        contentHeight: layout.height
        topMargin: Math.max(0, (height - contentHeight)/2)
        GridLayout {
            id: layout
            width: parent.width
            columns: 2
            Image {
                id: img
                fillMode: Image.PreserveAspectCrop
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            }
            Kirigami.Heading {
                id: title
                level: 1
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            Label {
                id: content
                Layout.columnSpan: 2
                Layout.fillWidth: true
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }
}
