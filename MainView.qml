import QtQuick 2.4
import QtQuick.Controls 2.4
import Mycroft 1.0 as Mycroft

StackView
{

    id: mainStack

    initialItem: Idler {
        id: initialPage
    }
    property string metadataType

    Mycroft.SkillLoader {
        id: skillLoader
    }

    Connections {
        target: Mycroft.MycroftController

        //These few lines are a cludge to make existing skills work that don't have metadata (yet)
        onFallbackTextRecieved: {
            var regex = /(.*)Skill*/;
            var found = skill.match(regex);
            if (found.length > 1) {
                openSkillUi(found[1].toLowerCase(), data);
            }
        }

        onSkillDataRecieved: {
            if (data["type"] === "stop") {
                //explictly unset
                if (mainStack.depth > 1) {
                    mainStack.pop();
                    mainStack.metadataType = "";
                }
                return;
            }
            openSkillUi(data["type"], data);
        }

        onSpeakingChanged: {
            if (!Mycroft.MycroftController.speaking) {
                if (mainStack.depth > 1) {
                    mainStack.pop(initialPage);
                    mainStack.metadataType = "";
                }
            }
        }
    }

    function openSkillUi(type, data) {
        var _url = skillLoader.uiForMetadataType(type);
        if (!_url) {
            return;
        }

        if (mainStack.metadataType == type) {
            var key;
            for (key in data) {
                if (mainStack.currentItem.hasOwnProperty(key)) {
                    mainStack.currentItem[key] = data[key];
                }
            }
        } else {
            mainStack.metadataType = type;
            if (mainStack.depth > 1) {
                mainStack.replace(_url, data);
            } else {
                mainStack.push(_url, data);
            }
        }
    }
}
