import QtQuick 2.4
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami

//TODO: should all delegates be a Kirigami Page?
Controls.Control {
    id: control
    property int graceTime: 6000
    //FIXME: all of this should be grouped
    property alias backgroundImage: img.source
    property alias backgroundHorizontalAlignment: img.horizontalAlignment
    property alias backgroundVerticalAlignment: img.verticalAlignment
    property alias backgroundDim: rect.opacity

    signal backRequested

    property Component controlBar: Controls.RoundButton {
        z: 99999
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: control.leftPadding
            bottomMargin: control.bottomPadding
        }
        icon.name: "go-previous-symbolic"
        onClicked: control.backRequested();
    }

    readonly property Item controlBarItem: controlBar.createObject(control);

    readonly property bool userInteracting: main.pressed

    //To do some automatic responsive layouting
    readonly property bool wideMode: Math.min(width, height) > Kirigami.Units.gridUnit * 18

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    leftPadding: (Controls.StackView.view ? Controls.StackView.view.leftPadding : 0) + Kirigami.Units.largeSpacing
    topPadding: (Controls.StackView.view ? Controls.StackView.view.topPadding : 0) + Kirigami.Units.largeSpacing
    rightPadding: (Controls.StackView.view ? Controls.StackView.view.rightPadding : 0) + Kirigami.Units.largeSpacing
    bottomPadding: (Controls.StackView.view ? Controls.StackView.view.bottomPadding : 0) + Kirigami.Units.largeSpacing

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

    contentItem: MouseArea {
        id: main
        drag.filterChildren: true
    }
}
