import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
     background: Mycroft.SlidingImage {
     source: sessionData.sampleImage
     running: bool    //If true the sliding animation is active
     speed: 0.1         //Animation speed in Kirigami.Units.gridUnit / second
   }
} 
