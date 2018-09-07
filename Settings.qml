import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft


Drawer {
    edge: Qt.TopEdge
    height: layout.implicitHeight + 2 * Kirigami.units.smallSpacing
    ColumnLayout {
        id: layout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.units.smallSpacing
        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: Kirigami.units.smallSpacing
            Kirigami.Icon {
                source: "go-home"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Mycroft.MycroftController.sendRequest("mycroft.stop", {});
                    }
                }
            }
            Kirigami.Icon {
                source: "foo"
            }
            Kirigami.Icon {
                source: "settings-configure"
            }
         }
         RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: Kirigami.units.smallSpacing
            Kirigami.Icon {
                source: "audio-volume-low"
            }
            Slider {
                Layout.fillWidth: true
            }
            Kirigami.Icon {
                source: "audio-volume-high"
            }
         }
    }
}
