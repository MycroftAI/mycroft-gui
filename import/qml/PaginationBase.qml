import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami

Item {
    property var pageWidth
    property var pageHeght
    property alias spacing: secondary.spacing
    width: pageWidth
    height: pageHeght

    readonly property Item primaryItem: secondaryItems ? secondaryItems[0] : null

    default property list<Item> secondaryItems
    onSecondaryItemsChanged: {
        if (layout.singleItem) {
            secondary.insertItem(0, primaryItem);
        }
        for (var i = 1; i < secondaryItems.length; ++i) {
            secondary.addItem(secondaryItems[i]);
        }
    }

    GridLayout {
        id: layout
        anchors.fill: parent
        //anchors.margins: 20
        property bool singleItem: columns < 2 && height < 800
        columns: width > 800 ? 2 : 1

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
        }

        Item {
            visible: !layout.singleItem
            id: mainItemPlaceHolder
            Layout.fillWidth: true
            Layout.fillHeight: true //fill width to evenly split layout
        }
        SwipeView {
            id: secondary
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: false
            spacing: Kirigami.Units.largeSpacing
        }
    }
}
