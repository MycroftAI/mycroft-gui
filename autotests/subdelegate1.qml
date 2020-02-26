 
import QtQuick 2.9
import QtQuick.Controls 2.0
import org.kde.lottie 1.0
import Mycroft 1.0 as Mycroft

Rectangle {
    color: "red"
    LottieAnimation {
        id: thinkingAnimation
        visible: true
        anchors.fill:parent
        source: Qt.resolvedUrl("./sunny.json")
        loops: Animation.Infinite
        fillMode: Image.PreserveAspectFit
        running: true
    }
}
