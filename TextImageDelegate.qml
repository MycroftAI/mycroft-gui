import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

BasicDelegateBase {
    property alias title: title.text
    property alias image: img.source
    property alias content: content.text

    backgroundImage: img.source

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
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            Layout.preferredHeight: Kirigami.Units.gridUnit * 5
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
        }
        Item {
            Layout.columnSpan: 2
            Layout.fillHeight: true
        }
    }
}
