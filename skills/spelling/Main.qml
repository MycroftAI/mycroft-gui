import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    backgroundHorizontalAlignment: Image.AlignLeft
    backgroundDim: 0

    property alias utterance: content.text

    ColumnLayout { //maybe a flickable in case there's too much text instead of Eliding (Flickable delegate base?)
        anchors {
            fill: parent
        }
        Kirigami.Heading {
            id: content
            Layout.fillWidth: true
            text: modelData.text
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
    }
}
