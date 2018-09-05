import QtQuick 2.4
import QtQuick.Controls 2.4
import Mycroft 1.0

StackView
{
    property Mycroft mycroft

    id: mainStack

    initialItem: Idler {}

    Connections {
        target: mycroft
        onSkillDataRecieved: {
            switch(skill) {
            case "JokingSkill.handle_general_joke":
                mainStack.push("skill-uis/Fallback/main.qml", data);
                break;
            case "TimeSkill.handle_query_time":
                mainStack.push("skill-uis/TimeSkill/main.qml", data);
                break;
            case "WikipediaSkill.handle_intent":
                if(data["utterance"]) return;
                mainStack.push("skill-uis/Wikipedia/main.qml", data);
            }
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
