import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Kirigami.ScrollablePage {
    title: "Hints"
    objectName: "hints"
    Controls.Label {
        text: "Usage hints go here"
    }
}
