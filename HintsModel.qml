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
