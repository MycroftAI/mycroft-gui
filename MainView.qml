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
                mainStack.push("TextDelegate.qml", {
                    "title": "",
                    "content": data["utterance"]
                });
                break;
            case "TimeSkill.handle_query_time":
                mainStack.push("TimeDelegate.qml");
                break;
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
