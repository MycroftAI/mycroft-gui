import QtQuick 2.4
import QtQuick.Controls 2.0 as Controls
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

    readonly property bool userInteracting: main.pressed

    //To do some automatic responsive layouting
    readonly property bool wideMode: Math.min(width, height) > Kirigami.Units.gridUnit * 18

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    /**
     * FIXME: do we want this at all?
     * If the delegate supports an own "back" action
     * it can reimplement this function and implement the going back in there.
     * @returns if true the delegate managed its own back action and the view won't pop it, if returns false the management of back is global and the delegate will be removed from the stack
     */
    function goBack() {
        return false;
    }
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
