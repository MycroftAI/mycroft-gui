import QtQuick 2.5
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.3
import Mycroft 1.0 as Mycroft
import org.kde.kirigami 2.5 as Kirigami

Row {
    Mycroft.StatusIndicator {
        id: indicator
    }
    ColumnLayout {
        Controls.Button {
            text: "Ok"
            onClicked: indicator.state = "ok"
        }
        Controls.Button {
            text: "Error"
            onClicked: indicator.state = "error"
        }
        Controls.Button {
            text: "Waiting"
            onClicked: indicator.state = "waiting"
        }
        Controls.Button {
            text: "Loading"
            onClicked: indicator.state = "loading"
        }
        Controls.Button {
            text: "Idle"
            onClicked: indicator.state = "idle"
        }
    }
}

