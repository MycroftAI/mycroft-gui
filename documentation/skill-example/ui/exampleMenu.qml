import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: exampleMenuView
    property var exampleModel: sessionData.menuBlob.menuItems
    
    Component.onCompleted: {
        console.log(sessionData.menuBlob)
    }
    
    Item {
        id: topArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Kirigami.Units.gridUnit * 2
        
        Kirigami.Heading {
            id: examplePageTextHeading
            level: 1
            wrapMode: Text.WordWrap
            anchors.centerIn: parent
            font.bold: true
            text: "GUI Examples"
            color: Kirigami.Theme.linkColor
        }
    }

    Item {
        anchors.top: topArea.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: areaSep.top
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        
        ListView {
            anchors.fill: parent
            clip: true
            model: exampleModel
            boundsBehavior: Flickable.StopAtBounds
            delegate: Kirigami.AbstractListItem {
                contentItem: Item {
                implicitWidth: delegateLayout.implicitWidth;
                implicitHeight: delegateLayout.implicitHeight;
        
                    ColumnLayout {
                        id: delegateLayout
                        anchors {
                            left: parent.left;
                            top: parent.top;
                            right: parent.right;
                        }
                    
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Math.round(units.gridUnit / 2)
                
                            Kirigami.Icon {
                                id: exampleMenuItemIcon
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                Layout.preferredHeight: units.iconSizes.medium
                                Layout.preferredWidth: units.iconSizes.medium
                                source: modelData.exampleIcon
                            }

                            
                            Kirigami.Heading {
                                id: exampleMenuItemLabel
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                height: paintedHeight
                                elide: Text.ElideRight
                                font.weight: Font.DemiBold
                                text: modelData.exampleLabel
                                textFormat: Text.PlainText
                                level: 2
                            }
                        }
                    }
                }
                
                onClicked: {
                        triggerEvent(modelData.exampleEvent, {})
                }
            }
        }
    }
    
    Kirigami.Separator {
        id: areaSep
        anchors.bottom: bottomArea.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
    }
    
    Item {
        id: bottomArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing * 1.15
        height: backIcon.implicitHeight + Kirigami.Units.largeSpacing * 1.15

        RowLayout {
            anchors.fill: parent
            
            Kirigami.Icon {
                id: backIcon
                source: "go-previous"
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            }
            
            Kirigami.Heading {
                level: 2
                wrapMode: Text.WordWrap
                font.bold: true
                text: "Home"
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                triggerEvent("mycroft.device.show.idle", {})
            }
        }
    }
}
