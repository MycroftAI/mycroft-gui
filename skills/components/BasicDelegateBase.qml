import QtQuick 2.4

Item
{
    property alias backgroundImage: img.source
    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }
    Rectangle {
        color: "black"
        anchors.fill: parent
        opacity: 0.6
    }
}
