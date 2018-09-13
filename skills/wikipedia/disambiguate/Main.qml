import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    property alias options: list.model
    ColumnLayout {
        anchors.fill: parent
        Kirigami.Heading {
            level: 1
            Layout.fillWidth: true
            text: "Did you mean..."
            wrapMode: Text.WordWrap
        }
        ListView {
            id: list
            Layout.fillHeight: true
            Layout.fillWidth: true
            delegate: Kirigami.BasicListItem {
                label: modelData
                onClicked: Mycroft.MycroftController.sendRequest("wikipedia:load_article", {"ArticleTitle": modelData})
            }
        }
    }
}

