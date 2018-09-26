/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
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
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.5 as Kirigami

ItemBase {
    id: root

    property var weatherData

    PlasmaCore.DataSource {
        id: geoDataSource
        dataEngine: "geolocation"
        connectedSources: sources

        onNewData: {
            fetchDashWeather();
        }
    }

    Component.onCompleted: fetchDashWeather()

    Timer {
        running: true
        repeat: true
        //update weather every 5 minutes
        interval: 5*60*1000
        onTriggered: fetchDashWeather();
    }
    function fetchDashWeather() {

        var doc = new XMLHttpRequest()
        var url = 'https://api.openweathermap.org/data/2.5/forecast?' +
        'lat=' + geoDataSource.data["location"].latitude + '&lon=' + geoDataSource.data["location"].longitude + '&units=' + "metric" + '&cnt=3' +
        '&APPID=' + "7af5277aee7a659fc98322c4517d3df7";

        doc.open("GET", url, true);
        doc.send();

        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                root.weatherData = JSON.parse(doc.responseText);
            }
        }
    }

    RowLayout {
        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.enormous
            Layout.preferredHeight: Layout.preferredWidth
            source: {
                if (!weatherData) {
                    return;
                }

                switch (weatherData.list[0].weather[0].icon) {
                case "01d":
                    return "weather-clear";
                case "02d":
                    return "weather-few-clouds";
                case "03d":
                    return "weather-clouds";
                case "04d":
                    return "weather-many-clouds";
                case "09d":
                    return "weather-showers";
                case "10d":
                    return "weather-showers-day";
                case "11d":
                    return "weather-storm-day";
                case "13d":
                    return "weather-snow-scattered-day";
                case "50d":
                    return "weather-fog";
                
                case "01n":
                    return "weather-clear-night";
                case "02n":
                    return "weather-few-clouds-night";
                case "03n":
                    return "weather-clouds-night";
                case "04n":
                    return "weather-many-clouds";
                case "09n":
                    return "weather-showers";
                case "10n":
                    return "weather-showers-night";
                case "11n":
                    return "weather-storm-night";
                case "13n":
                    return "weather-snow-scattered-night";
                case "50n":
                    return "weather-fog";
                }
            }
        }
        Kirigami.Heading {
            text: weatherData ? i18n("%1°C, %2", Math.round(weatherData.list[0].main.temp), weatherData.list[0].weather[0].description) : ""
        }
    }
}

