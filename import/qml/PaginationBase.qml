import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item
{
    default property alias secondaryItems: secondary.contentData

    width: 900 //FIXME
    height: 500

    GridLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 20
        property bool singleItem: columns < 2 && height < 800
        columns: width > 800 ? 2 : 1

        onSingleItemChanged: {
            if (singleItem) {
                foo = mainItemPlaceHolder.children[0];
                foo.layer.enabled = false //DAVE This is a hack round something..but I don't know what
                secondary.insertItem(0, foo)
            } else {
                var foo = secondary.takeItem(0);
                console.log(foo.color);
                foo.parent = mainItemPlaceHolder
                foo.visible = true
                foo.opacity = 1
                foo.layer.enabled = true //see above
                foo.width = Qt.binding(function() {return mainItemPlaceHolder.width})
                foo.height = Qt.binding(function() {return mainItemPlaceHolder.height})
            }
        }

        Rectangle {
            visible: !layout.singleItem
            id: mainItemPlaceHolder
            Layout.fillWidth: true
            Layout.fillHeight: true //fill width to evenly split layout
        }
        SwipeView {
            id: secondary
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
        }
    }
}
