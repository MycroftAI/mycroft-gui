import QtQuick 2.4
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.4 as Kirigami

Controls.Control {
    id: control
    //FIXME: all of this should be grouped
    property alias backgroundImage: img.source
    property alias backgroundHorizontalAlignment: img.horizontalAlignment
    property alias backgroundVerticalAlignment: img.verticalAlignment
    property alias backgroundDim: rect.opacity

    //To do some automatic responsive layouting
    readonly property bool wideMode: Math.min(width, height) > Kirigami.Units.gridUnit * 18

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    leftPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

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
            id: rect
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
