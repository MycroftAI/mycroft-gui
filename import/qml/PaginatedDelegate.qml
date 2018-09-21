import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami

DelegateBase {
    id: root
    property int switchWidth: Kirigami.Units.gridUnit * 35
    property int switchHeight: Kirigami.Units.gridUnit * 35
    readonly property Kirigami.Page primaryPage: pages ? pages[0] : null

    property alias currentIndex: secondary.currentIndex
    property alias currentItem: secondary.currentItem
    property alias count: secondary.count

    default property list<Kirigami.Page> pages

    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0

    onPagesChanged: {
        if (layout.singleItem) {
            secondary.insertItem(0, primaryPageInsideHolder);
        }
        primaryPage.anchors.fill = Qt.binding(function() {return primaryPage.parent;})
        for (var i = 1; i < pages.length; ++i) {
            secondary.addItem(pages[i]);
        }
        secondary.currentIndex = 0;
    }

    //This is because this is going to have a null parent for a while, leading to the creation of a ShaderEffectSource on it which will break its input,
    //with a container outside the page, we can reparent the page before removing the container
    Item {
        id: primaryPageInsideHolder
        visible: layout.singleItem
        readonly property Flickable flickable: primaryPage.flickable
    }
    GridLayout {
        id: layout
        anchors.fill: parent

        property bool singleItem: columns < 2 && height < switchWidth
        columns: width > switchHeight ? 2 : 1

        onSingleItemChanged: {
            if (singleItem) {
                if (primaryPage.hasOwnProperty("layer")) {
                    primaryPageInsideHolder.layer.enabled = false //DAVE This is a hack round something..but I don't know what
                }
                primaryPage.parent = primaryPageInsideHolder;
                secondary.insertItem(0, primaryPageInsideHolder);
                primaryPageInsideHolder.visible = true;
                primaryPageInsideHolder.opacity = 1;
            } else {
                console.log(primaryPage.color);
                if (secondary.itemAt(0) != primaryPageInsideHolder) {
                    console.error("ERROR: the first item is not primaryPage: this should never happen")
                    return;
                }
                primaryPageInsideHolder.visible = false
                secondary.takeItem(0);
                primaryPage.parent = primaryPageOutsideHolder;
            }
            secondary.currentIndex = 0;
        }

        Item {
            id: primaryPageOutsideHolder
            z: secondary.z + 1
            visible: !layout.singleItem
            Layout.fillWidth: true
            Layout.fillHeight: true //fill width to evenly split layout
        }
        Controls.SwipeView {
            id: secondary
            currentIndex: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
        }
    }

    LinearGradient {
        anchors {
            left: parent.left
            top: bottomBar.top
            right: parent.right
            bottom: parent.bottom
        }
        visible: bottomBar.visible
        start: Qt.point(0, 0)
        end: Qt.point(0, height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    RowLayout {
        id: bottomBar
        visible: secondary.contentChildren.length > 1
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: Kirigami.Units.largeSpacing
        }
        width: secondary.width - Kirigami.Units.largeSpacing*2
        Controls.RoundButton {
            icon.name: "go-previous-symbolic"
            enabled: secondary.currentIndex > 0
            onClicked: secondary.currentIndex--
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Controls.PageIndicator {
                anchors.centerIn: parent
                count: secondary.count
                currentIndex: secondary.currentIndex
            }
        }
        Controls.RoundButton {
            icon.name: "go-next-symbolic"
            enabled: secondary.currentIndex < secondary.count - 1
            onClicked: secondary.currentIndex++
        }
    }
}
