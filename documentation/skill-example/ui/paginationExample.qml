import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
     Mycroft.PaginatedText {
         anchors.fill: parent
         text: sessionData.sampleText //The text that should be displayed
         currentIndex: 0   //The currently visible page number (starting from 0)
     }
}
