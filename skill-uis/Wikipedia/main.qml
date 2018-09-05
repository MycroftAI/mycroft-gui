import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import "../components"

BasicDelegateBase {
    property alias title: title.text
    property alias image: img.source
    property alias content: content.text

    backgroundImage: img.source

    Component.onCompleted: {
        console.log(image, text)
    }

    GridLayout { //maybe a flickable in case there's too much text instead of Eliding (Flickable delegate base?)
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        columns: 2
        Item {
            Layout.fillHeight: true
            Layout.columnSpan: 2
        }
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
            text: modelData.title
            wrapMode: Text.WordWrap
        }
        Label {
            id: content
            Layout.columnSpan: 2
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: "#EEE"
        }
        Item {
            Layout.columnSpan: 2
            Layout.fillHeight: true
        }
    }
}
