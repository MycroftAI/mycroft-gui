import QtQuick 2.4
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.4 as Kirigami

Controls.Control {
    id: control
    property alias backgroundImage: img.source

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    //this to make all items children of contentItem so everything will have paddings automagically
    default property alias data: main.data
    //TODO: make this background an internal component
    //so the implementation can do background.image: "foo" background.dim: 0.6 etc as grouped properties
    background: Item {
        Image {
            id: img
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            anchors.fill: parent
            //TODO: api for having skills that just fill a solid color
            color: "black"
            opacity: 0.6
        }
    }

    contentItem: Item {
        id: main
    }
}
