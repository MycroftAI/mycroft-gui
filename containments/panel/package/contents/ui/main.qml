/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

import org.kde.plasma.private.minishell 2.0 as MiniShell
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

import "LayoutManager.js" as LayoutManager

import "quicksettings"

PlasmaCore.ColorScope {
    id: root
    width: 480
    height: 640
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    property Item toolBox
    property var layoutManager: LayoutManager

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(appletIconsRow)
        print("Applet added: " + applet + " " + applet.title)
        container.width = units.iconSizes.medium
        container.height = container.height

        applet.parent = container;
        container.applet = applet;
        applet.anchors.fill = container;
        applet.visible = true;
        applet.expanded = false;
        container.visible = true;
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
    }

    //this for now just takes them into account, no visualization
    PlasmaCore.DataSource {
        id: statusNotifierSource
        engine: "statusnotifieritem"
        interval: 0
        onSourceAdded: {
            connectSource(source)
        }
        Component.onCompleted: {
            connectedSources = sources
        }
    }

    RowLayout {
        id: appletsLayout
        Layout.minimumHeight: Math.max(root.height, Math.round(Layout.preferredHeight / root.height) * root.height)
    }
 
    Component {
        id: appletContainerComponent
        Item {
            //not used yet
            property bool animationsEnabled: false
            property Item applet
            Layout.fillHeight: true
            Layout.minimumWidth: applet && applet.compactRepresentationItem ? Math.max(applet.compactRepresentationItem.Layout.minimumWidth, appletIconsRow.height) : appletIconsRow.height
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    MouseArea {
        z: 99

        anchors.fill: parent
        onPressed: {
            slidingPanel.peeking = true;
            panelWindow.showFullScreen();
        }
        onPositionChanged: {
            slidingPanel.position = mouse.y/slidingPanel.contentItem.height;
        }
        onReleased: {
            slidingPanel.peeking = false;
        }
        WindowControl {
            id: windowControl
            anchors.fill: parent
        }
        RowLayout {
            id: appletIconsRow
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                margins: Kirigami.units.smallSpacing
            }
            visible: !windowControl.visible
            readonly property int implicitHeight: children.length > 0 ? Kirigami.Units.gridUnit * 5 : 0
            layer.enabled: true
            layer.effect: DropShadow {
                opacity: root.opacity
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 2
            }
            Row {
                spacing: Kirigami.Units.smallSpacing
                Layout.fillHeight: true
                Repeater {
                    id: statusNotifierRepeater
                    model: PlasmaCore.SortFilterModel {
                        id: filteredStatusNotifiers
                        filterRole: "Title"
                        sourceModel: PlasmaCore.DataModel {
                            dataSource: statusNotifierSource
                        }
                    }

                    delegate: TaskWidget {
                    }
                }
            }
        }
    }

    MiniShell.FullScreenPanel {
        id: panelWindow
        visible: false
        width: Screen.width
        height: Screen.height
        color: Qt.rgba(0, 0, 0, 0.6 * slidingPanel.position)
        SlidingPanel {
            id: slidingPanel
            width: plasmoid.availableScreenRect.width
            onVisibleChanged: panelWindow.visible = visible;
            bottomItem: Item {}
        }
    }
}
