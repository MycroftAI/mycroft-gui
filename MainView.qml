import QtQuick 2.4
import QtQuick.Controls 2.4
import Mycroft 1.0 as Mycroft

StackView
{

    id: mainStack

    initialItem: Idler {}
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
                data["type"] = "fallback"
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
                return;
            }

            if (mainStack.metadataType == data["type"]) {
                Object.assign(mainStack.currentItem, data);
            } else {
                if (mainStack.depth > 1) {
                    mainStack.pop();
                }
                mainStack.metadataType = data["type"];
                mainStack.push(_url, data);
            }
        }

        onSpeakingChanged: {
            if (!Mycroft.MycroftController.speaking) {
                if (mainStack.depth > 1) {
                    mainStack.pop();
                }
            }
        }
    }
}
