import QtQuick 2.5
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.3
import Mycroft 1.0 as Mycroft
import org.kde.kirigami 2.5 as Kirigami

Mycroft.BoxLayout {
    id: root
    width: 400
    height: 600
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "red"
    }
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "Blue"
    }
}

