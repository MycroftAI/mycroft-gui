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
        onSkillDataRecieved: {
            //These few lines are a cludge to make existing skills work that don't have metadata (yet)
            switch(Mycroft.MycroftController.currentSkill) {
            case "JokingSkill.handle_general_joke":
                data["type"] = "joke"
                break;
            case "TimeSkill.handle_query_time":
                data["type"] = "time"
                break;
            }


            if (!data["type"]) {
                return;
            }


            var _url = skillLoader.uiForMetadataType(data["type"]);
            if (!_url) {
                if (mainStack.depth > 1) {
                    mainStack.pop();
                    mainStack.metadataType = "";
                }
            }

            if (mainStack.metadataType == data["type"]) {
                var key;
                for (key in data) {
                    if (mainStack.currentItem.hasOwnProperty(key)) {
                        mainStack.currentItem[key] = data[key];
                    }
                }
            } else {
                mainStack.metadataType = data["type"];
                if (mainStack.depth > 1) {
                    mainStack.replace(_url, data);
                } else {
                    mainStack.push(_url, data);
                }
            }
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
}
