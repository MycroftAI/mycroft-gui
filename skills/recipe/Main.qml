import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    property alias recipeTitle: title.text
    property alias recipeImage: img.source
    property alias recipeCalories: contentCalorie.text
    property alias recipeDietType: contentDietType.text
    property alias recipeHealthTag: contentHealthTag.text
    property alias recipeSource: contentSource.text
    property var recipeIngredients 
    
    backgroundImage: img.source

    Component.onCompleted: {
        console.log(JSON.stringify(recipeIngredients))
    }

    GridLayout { //maybe a flickable in case there's too much text instead of Eliding (Flickable delegate base?)
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        columns: 2
        Item {
            Layout.fillHeight: true
            Layout.columnSpan: 2
        }
        
        Image {
            id: img
            fillMode: Image.PreserveAspectCrop
            Layout.preferredWidth: Kirigami.Units.gridUnit * 4
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
        }

        ColumnLayout {
            Layout.fillWidth: true
            Kirigami.Heading {
                id: title
                level: 1
                Layout.fillWidth: true
                //text: modelData.title
                wrapMode: Text.WordWrap
                color: "#EEE"
            }


            Row {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    id: contentSourceLabel
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                    text: "Source:"
                }

                Label {
                    id: contentSource
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                }

            }

            Row {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    id: contentCalorieLabel
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                    text: "Calories:"
                }

                Label {
                    id: contentCalorie
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                }

            }

            Row {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    id: contentDietTypeLabel
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                    text: "Diet Type:"
                }

                Label {
                    id: contentDietType
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                }

            }

            Row {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    id: contentHealthTagLabel
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                    text: "Health Tags:"
                }


                Label {
                    id: contentHealthTag
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: "#EEE"
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.columnSpan: 2

            ColumnLayout{
                Layout.fillWidth: true

                Kirigami.Heading {
                    id: ingredientsLabel
                    level: 1
                    Layout.fillWidth: true
                    //text: modelData.title
                    wrapMode: Text.WordWrap
                    color: "#EEE"
                    text: "Ingredients:"
                }

                ListView {
                    id: ingredientsList
                    Layout.fillWidth: true
                    implicitHeight: 200
                    delegate: Label {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        color: "#EEE"
                        text: modelData
                    }
                    model: recipeIngredients.ingredients
                }
            }
        }

        Item {
            Layout.columnSpan: 2
            Layout.fillHeight: true
        }
    }
}

