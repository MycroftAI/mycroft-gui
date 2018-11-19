 
import QtQuick 2.4
import QtQuick.Layouts 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.AbstractDelegate {
    Rectangle {
        anchors.fill:parent
    }
    Column {
        Text {
            text: sessionData.icon
        }
        Text {
            text: sessionData.temperature
        }
    }
}
