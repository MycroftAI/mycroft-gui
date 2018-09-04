import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

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
            level: 1
            text: modelData.title
            wrapMode: Text.WordWrap
        }
        Label {
            id: content
            text: modelData.text
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
        Item {
            Layout.fillHeight: true
        }
    }

}
