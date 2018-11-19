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
