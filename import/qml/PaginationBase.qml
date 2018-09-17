import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami

Item {
    id: root
    property alias spacing: secondary.spacing
    property int switchWidth: Kirigami.Units.gridUnit * 35
    property int switchHeight: Kirigami.Units.gridUnit * 35

    readonly property Item primaryItem: items ? items[0] : null

    default property list<Item> items

    onItemsChanged: {
        if (layout.singleItem) {
            secondary.insertItem(0, primaryItem);
        }
        for (var i = 1; i < items.length; ++i) {
            secondary.addItem(items[i]);
        }
        secondary.currentIndex = 0;
    }

    GridLayout {
        id: layout
        anchors.fill: parent
        //anchors.margins: 20
        property bool singleItem: columns < 2 && height < switchWidth
        columns: width > switchHeight ? 2 : 1

        onSingleItemChanged: {
            if (singleItem) {
                if (primaryItem.hasOwnProperty("layer")) {
                    primaryItem.layer.enabled = false //DAVE This is a hack round something..but I don't know what
                }
                secondary.insertItem(0, primaryItem)
            } else {
                console.log(primaryItem.color);
                if (secondary.itemAt(0) != primaryItem) {
                    console.error("ERROR: the first item is not primaryItem: this should never happen")
                    return;
                }
                secondary.takeItem(0);
                primaryItem.parent = mainItemPlaceHolder
                primaryItem.x = 0;
                primaryItem.visible = true
                primaryItem.opacity = 1
                if (primaryItem.hasOwnProperty("layer")) {
                    primaryItem.layer.enabled = true //see above
                }
                //FIXME: should this be unbinded when going to singleItem?
                primaryItem.width = Qt.binding(function() {return mainItemPlaceHolder.width})
                primaryItem.height = Qt.binding(function() {return mainItemPlaceHolder.height})
            }
            secondary.currentIndex = 0;
        }

        Item {
            visible: !layout.singleItem
            id: mainItemPlaceHolder
            Layout.fillWidth: true
            Layout.fillHeight: true //fill width to evenly split layout
        }
        SwipeView {
            id: secondary
            currentIndex: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: false
            spacing: Kirigami.Units.largeSpacing
        }
    }
    PageIndicator {
        visible: secondary.contentChildren.length > 1
        count: secondary.count
        currentIndex: secondary.currentIndex

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Label {text: secondary.currentIndex}
}
