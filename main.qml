import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Window 2.2
import Mycroft 1.0 as Mycroft

import "containments/panel/package/contents/ui" as Panel

Kirigami.ApplicationWindow {
    id: root
    visible: true

    minimumHeight : deviceHeight || undefined
    maximumHeight : deviceHeight || undefined
    minimumWidth : deviceWidth || undefined
    maximumWidth : deviceWidth || undefined
    x: deviceWidth ? Screen.desktopAvailableHeight - width : undefined
    y: deviceHeight ? Screen.desktopAvailableHeight - height : undefined

    //HACK!! needs proper api in kirigami
    Component.onCompleted: {
        globalDrawer.handle.handleAnchor = handleAnchor;
    }

    globalDrawer: Kirigami.GlobalDrawer {
        title: "Mycroft"
        bannerImageSource: "banner.png"
        handleVisible: !hideTextInput

        actions: [
            Kirigami.Action {
                text: "Hints"
                iconName: "help-hint"
                checked: pageStack.layers.currentItem.objectName == "hints"
                onTriggered: {
                    if (checked) {
                        pageStack.layers.pop(pageStack.layers.initialItem);
                    } else {
                        pageStack.layers.push(Qt.resolvedUrl("HintsPage.qml"));
                    }
                }
            }
        ]
    }

    //FIXME: this should be so much to be killed
    Panel.SlidingPanel {
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        //to change the color of the entire panel, uncomment this
       // Kirigami.Theme.colorSet: Kirigami.Theme.Window
        width: root.width
    }
    pageStack.globalToolBar.style: pageStack.layers.depth == 1 ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.Auto

    pageStack.initialPage: Image {
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        source: "background.png"
        anchors.fill: parent

        Mycroft.StackSkillView {
            id: mainView
            anchors.fill: parent
            initialItem: Idler {}
            Layout.fillHeight: true
            Layout.fillWidth: true

            Mycroft.StatusIndicator {
                id: si
                visible: true
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: Kirigami.Units.largeSpacing
                }
                z: 999
            }
        }
    }

    footer: RowLayout {
        visible: !hideTextInput
        Item {
            id: handleAnchor
            Layout.fillHeight: true
            Layout.preferredWidth: height
        }
        TextField {
            Layout.fillWidth: true
            id: qinput
            onAccepted: {
                Mycroft.MycroftController.sendText(qinput.text)
            }
        }
    }
}


