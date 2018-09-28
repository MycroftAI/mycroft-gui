import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Kirigami.ScrollablePage {
    title: "Hints"
    objectName: "hints"
    
    Kirigami.CardsListView {
        id: skillslistmodelview
        anchors.fill: parent;
        clip: true;
        model: HintsModel{}
        delegate: Kirigami.AbstractCard {
            id: skillDelegate;

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

                    Kirigami.Heading {
                        id: skillName
                        Layout.fillWidth: true;
                        wrapMode: Text.WordWrap;
                        font.bold: true;
                        text: qsTr(model.Skill);
                        level: 3;
                        color: Kirigami.Theme.textColor;
                    }

                    RowLayout {
                        id: skillTopRowLayout
                        spacing: Kirigami.Units.largeSpacing
                        Layout.fillWidth: true;

                        Image {
                            id: innerskImg
                            source: model.Pic;
                            fillMode: PreserveAspectFit
                            Layout.preferredWidth: innerskImg.width
                            Layout.preferredHeight: innerskImg.height
                            width: Kirigami.Units.gridUnit * 2
                            height: Kirigami.Units.gridUnit * 2
                        }

                        ColumnLayout {
                            id: innerskillscolumn
                            spacing: 2;
                            Controls.Label {
                                wrapMode: Text.WordWrap;
                                width: skillDelegate.width;
                                color: Kirigami.Theme.textColor;
                                text: qsTr(model.CommandList.get(0).Commands);
                            }
                            Controls.Label {
                                wrapMode: Text.WordWrap;
                                width: skillDelegate.width;
                                color: Kirigami.Theme.textColor;
                                text: qsTr(model.CommandList.get(1).Commands);
                            }
                        }
                    }
                }
            }
        }
    }
}
