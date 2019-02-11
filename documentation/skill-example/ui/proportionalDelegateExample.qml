import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft
import org.kde.lottie 1.0

Mycroft.ProportionalDelegate {
    id: root

    LottieAnimation {     
        id: fancyAnimation 
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Math.min(root.contentWidth, proportionalGridUnit * 50)
        Layout.preferredHeight: Layout.preferredWidth
        source: Qt.resolvedUrl("animations/settings.json")
        loops: Animation.Infinite
        fillMode: Image.PreserveAspectFit    
        running: true
    }    

    Mycroft.AutoFitLabel {
        id: dayLabel
        font.weight: Font.Bold
        Layout.fillWidth: true
        Layout.preferredHeight: proportionalGridUnit * 40
        text: sessionData.sampleText
    }
} 
