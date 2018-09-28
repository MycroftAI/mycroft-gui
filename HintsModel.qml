import QtQuick 2.9

ListModel {
    id: skillshintmodel
    ListElement {
        Pic: "alarm.png"
        Skill: "Alarm"
        CommandList: [
         ListElement { Commands: "Hey Mycroft, Set alarm for %time" },
         ListElement { Commands: "Hey Mycroft, Set alarm for %time on %date" }
        ]
    }

    ListElement {
        Pic: "dateandtime.png"
        Skill: "Date & Time"
        CommandList: [
        ListElement { Commands: "Hey Mycroft, What is the current time" },
        ListElement { Commands: "Hey Mycroft, Current date in London" }
        ]
    }

    ListElement {
        Pic: "desktop.png"
        Skill: "Applications"
        CommandList: [
        ListElement { Commands: "Hey Mycroft, Open Firefox"},
        ListElement { Commands: "Hey Mycroft, Open Konsole"}
        ]
    }

    ListElement {
        Pic: "joke.png"
        Skill: "Joke"
        CommandList: [
        ListElement {Commands: "Hey Mycroft, Tell me a joke"},
        ListElement {Commands: "Hey Mycroft, Meaning of life"}
        ]
    }

    ListElement {
        Pic: "spell.png"
        Skill: "Spell"
        CommandList: [
        ListElement {Commands: "Hey Mycroft, Spell Hello"},
        ListElement {Commands: "Hey Mycroft, Spell Mycroft"}
        ]
    }

    ListElement {
        Pic: "wikip.png"
        Skill: "WiKi"
        CommandList: [
        ListElement {Commands: "Hey Mycroft, Wiki the Moon"},
        ListElement {Commands: "Hey Mycroft, Define Relativity"}
        ]
    }

    ListElement {
        Pic: "wolfram.png"
        Skill: "Wolfram Alpha"
        CommandList: [
        ListElement {Commands: "Hey Mycroft, Calculate the Pi"},
        ListElement {Commands: "Hey Mycroft, What is 2+2"}
        ]
    }

    ListElement {
        Pic: "weather.png"
        Skill: "Weather"
        CommandList: [
        ListElement {Commands: "Hey Mycroft, What is the current weather"},
        ListElement {Commands: "Hey Mycroft, Current weather in Tokyo"}
        ]
    }
} 
