import QtQuick 2.5
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.3
import Mycroft 1.0 as Mycroft
import org.kde.kirigami 2.5 as Kirigami

Mycroft.PaginatedDelegate {
    id: root
    width: 500
    height: 500

    Kirigami.ScrollablePage {
        Rectangle {
            width: page1.width
            implicitHeight: page1.height
            color: "red"
        }
    }

    Kirigami.ScrollablePage {
        id: page1
        Rectangle {
            width: page1.width
            implicitHeight: page1.height
            color: "yellow"
        }
    }
    Kirigami.ScrollablePage {
        Rectangle {
            width: page1.width
            implicitHeight: page1.height
            color: "blue"
        }
    }
    Kirigami.ScrollablePage {
        Rectangle {
            width: page1.width
            implicitHeight: page1.height
            color: "green"
        }
    }
}
