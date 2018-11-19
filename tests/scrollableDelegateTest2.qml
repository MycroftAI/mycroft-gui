import QtQuick 2.5
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.3
import Mycroft 1.0 as Mycroft
import org.kde.kirigami 2.5 as Kirigami

Mycroft.ScrollableDelegate {
    id: root
    width: 500
    height: 500

    Rectangle {
        color: "red"
        radius: 30
        width: 300
        height: 700
    }
}

