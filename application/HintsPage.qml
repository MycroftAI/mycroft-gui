/*
 * Copyright 2018 Marco Martin <mart@kde.org>
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
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
            var fileName = getList[i] + "/" + fileToFind;
            var fileParse = Mycroft.FileReader.read(fileName);
            console.log("Loading hints from", fileName);
            var matchedRegex = getDataFromRegex(fileName, fileParse, /<img[^>]*src='([^']*)'.*\/>\s(.*)/g)
            var matchedExamples = getDataFromRegex(fileName, fileParse, /Examples \n.*"(.*)"\n\*\s"(.*)"/g)
            var matchedCategory = getDataFromRegex(fileName, fileParse, /## Category\n\*\*(.*)\*\*/g)
            if(matchedRegex !== null && matchedRegex.length > 0 && matchedExamples !== null && matchedExamples.length > 0 && matchedCategory !== null && matchedCategory.length > 0) {
                console.log("All good. \n");
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

    function getDataFromRegex(fileName, fileText, matchRegex){
        var re = new RegExp(matchRegex);
        var match = re.exec(fileText);
        if (match === null || match.length == 0) {
            console.log("README.md file is not properly defined, it's missing data for the following regex:");
            console.log(re);
            console.log("Please fix the README.md file of the skill");
            console.log("This warning is for skill developers");
            console.log("if you are not a developer, fill a bug on the corresponding skill.\n");
        }
        return match;
    }

    Kirigami.CardsListView {
        id: skillslistmodelview
        anchors.fill: parent;
        clip: true;
        model: modelCreatedObject
        delegate: HintsDelegate {
            imageSource: modelData.imgSrc
            title: modelData.title
            examples: modelData.examples
            category: modelData.category
        }
    }
}
