/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *  Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Kirigami.ScrollablePage {
    title: "Hints"
    objectName: "hints"
    property var modelCreatedObject
    
    Component.onCompleted: {
        createHintModel()
    }

    function createHintModel(){
        var hintList = []
        var defaultFold = '/opt/mycroft/skills'
        var fileToFind = "README.md"
        var getList = Mycroft.FileReader.checkForMeta(defaultFold, fileToFind)
        for(var i=0; i < getList.length; i++){
            var fileParse = Mycroft.FileReader.read(getList[i]+"/"+fileToFind);
            var matchedRegex = getImgSrc(fileParse)
            var matchedExamples = getExamples(fileParse)
            var matchedCategory = getCategory(fileParse)
            if(matchedRegex !== null && matchedRegex.length > 0 && matchedExamples !== null && matchedExamples.length > 0 && matchedCategory !== null && matchedCategory.length > 0) {
                var metaFileObject = {
                    imgSrc: matchedRegex[1],
                    title: matchedRegex[2],
                    category: matchedCategory[1],
                    examples: matchedExamples
                }
                hintList.push(metaFileObject);
            }
        }
        modelCreatedObject = hintList
    }

    function getImgSrc(fileText){
        var re = new RegExp(/<img[^>]*src='([^']*)'.*\/>\s(.*)/g);
        var match = re.exec(fileText);
        return match;
    }

    function getExamples(fileText){
        var re = new RegExp(/Examples \n.*"(.*)"\n\*\s"(.*)"/g);
        var match = re.exec(fileText);
        return match;
    }

    function getCategory(fileText){
        var re = new RegExp(/## Category\n\*\*(.*)\*\*/g);
        var match = re.exec(fileText);
        return match;
    }
    
    Kirigami.CardsListView {
        id: skillslistmodelview
        anchors.fill: parent;
        clip: true;
        model: modelCreatedObject
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
                        text: qsTr(modelData.title);
                        level: 3;
                        color: Kirigami.Theme.textColor;
                    }

                    RowLayout {
                        id: skillTopRowLayout
                        spacing: Kirigami.Units.largeSpacing
                        Layout.fillWidth: true;

                        Image {
                            id: innerskImg
                            source: modelData.imgSrc;
                            fillMode: PreserveAspectFit
                            Layout.preferredWidth: innerskImg.width
                            Layout.preferredHeight: innerskImg.height
                            width: Kirigami.Units.gridUnit * 2
                            height: Kirigami.Units.gridUnit * 2
                        }
                        
                        ColorOverlay {
                            id: colorOverlay
                            anchors.fill: innerskImg
                            source: innerskImg
                            color: Kirigami.Theme.linkColor
                        }

                        ColumnLayout {
                            id: innerskillscolumn
                            spacing: 2;
                            Controls.Label {
                                wrapMode: Text.WordWrap;
                                width: skillDelegate.width;
                                color: Kirigami.Theme.textColor;
                                text: modelData.examples[1];
                            }
                            Controls.Label {
                                wrapMode: Text.WordWrap;
                                width: skillDelegate.width;
                                color: Kirigami.Theme.textColor;
                                text: modelData.examples[2];
                            }
                        }
                    }
                }
            }
        }
    }
}
