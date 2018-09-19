/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

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
    }

    Window {
        id: panelWindow
        color: "transparent"
        visible: false
        SlidingPanel {
            id: slidingPanel
            width: plasmoid.availableScreenRect.width
            onVisibleChanged: {
                if (visible) {
                    panelWindow.showFullScreen();
                } else {
                    panelWindow.visible = false;
                }
            }
            bottomItem: RowLayout {
                id: appletIconsRow
                readonly property int implicitHeight: children.length > 0 ? Kirigami.Units.gridUnit * 5 : 0
            }
        }
    }
}
