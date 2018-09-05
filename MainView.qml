import QtQuick 2.4
import QtQuick.Controls 2.4
import Mycroft 1.0

StackView
{
    property Mycroft mycroft

    id: mainStack

    initialItem: Idler {}

    SkillLoader {
        id: skillLoader
    }

    Connections {
        target: mycroft
        onSkillDataRecieved: {
            //These few lines are a cludge to make existing skills work that don't have metadata (yet)
            switch(mycroft.currentSkill) {
            case "JokingSkill.handle_general_joke":
                data["type"] = "Fallback"
                break;
            case "TimeSkill.handle_query_time":
                data["type"] = "Time"
                break;
            }

            if (!data["type"]) {
                return;
            }

            var url = skillLoader.uiForMetadataType(data[type]);
            if (!url) {
                return;
            }

            mainStack.push(url, data);
        }

        onSpeakingChanged: {
            if (!mycroft.speaking) {
                if (mainStack.depth > 1) {
                    mainStack.pop();
                }
            }
        }
    }
}
