import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import Mycroft 1.0 as Mycroft

ColumnLayout {
    width: 500
    height: 500

    TextField {
        id: input
        Layout.fillWidth: true
        onAccepted: {
            Mycroft.MycroftController.sendText(input.text)
        }
    }
    Component.onCompleted: Mycroft.MycroftController.start();

    ScrollView {
        id: scroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        Flickable {
            contentWidth: width
            contentHeight: layout.height
            GridLayout {
                id: layout
                width: scroll.width - 20
                columns: 2
                //horizontalSpacing: 5
                Mycroft.StackSkillView {
                    Layout.rowSpan: 2
                    clip:true
                    width: 400
                    height: 800
                }
                Mycroft.StackSkillView {
                    clip: true
                    width: 800
                    height: 400
                }
                Mycroft.StackSkillView {
                    clip: true
                    width: 400
                    height: 400
                }
            }
        }
    }
}
