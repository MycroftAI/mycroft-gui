/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as Controls
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami

import "LayoutManager.js" as LayoutManager

import Mycroft 1.0 as Mycroft

Item {
    id: root
    width: 480
    height: 640

//BEGIN properties
    property Item toolBox
    property var layoutManager: LayoutManager
    readonly property bool smallScreenMode: Math.min(width, height) < Kirigami.Units.gridUnit * 18
//END properties

//BEGIN functions
    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(root, {"applet": applet})
        container.applet = applet;
        container.visible = true
        print("Applet added: " + applet)

        var appletWidth = applet.width;
        var appletHeight = applet.height;
        applet.parent = container;
        applet.anchors.fill = container;
        applet.visible = true;
        container.visible = true;

        // If the provided position is valid, use it.
        if (x >= 0 && y >= 0) {
            var index = LayoutManager.insertAtCoordinates(container, x , y);

        // Fall through to determining an appropriate insert position.
        } else {
            var before = null;
            //container.animationsEnabled = false;

            if (before) {
                LayoutManager.insertBefore(before, container);

            // Fall through to adding at the end.
            } else {
                container.parent = appletsSpace.layout;
            }
        }
    }
//END functions

//BEGIN slots
    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsSpace.layout;
        LayoutManager.restore();

        Mycroft.MycroftController.start();
    }

    Timer {
        interval: 10000
        running: Mycroft.MycroftController.status != Mycroft.MycroftController.Open
        onTriggered: {
            print("Trying to connect to Mycroft");
            Mycroft.MycroftController.start();
        }
    }

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

//END slots

    Component {
        id: appletContainerComponent
        MouseArea {
            id: appletContainer
            //not used yet
            property bool animationsEnabled: true
            property Item applet
            z: applet && applet.compactRepresentationItem && applet.expanded ? 99 : 0
            opacity: 1 - Math.abs(y/(height/2))

            Connections {
                target: plasmoid

                onAppletRemoved: {
                    print("Applet removed Applet-" + applet.id)
                    if (applet.id == appletContainer.applet.id) {
                        appletContainer.destroy();
                    }
                }
            }

            //this will kill any mouse events to the applet
            //first version is not interactive
/*            MouseArea {
                anchors.fill: parent
                z: 9999
                onPressed: mouse.accepted = true
            }
*/
            DropShadow {
                visible: applet && applet.backgroundHints == PlasmaCore.Types.StandardBackground
                anchors.fill: parent
                horizontalOffset: 0
                verticalOffset: 2
                source: applet
            }

            implicitWidth: root.smallScreenMode || appletsSpace.layout.children.length < 2 ? appletsView.width :  Math.max(applet.switchWidth + 1, Math.max( applet.Layout.minimumWidth, appletsView.width/2))
            implicitHeight: appletsView.height

            PlasmaComponents.BusyIndicator {
                z: 1000
                visible: applet && applet.busy
                running: visible
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
            }
        }
    }

/*NOTE: for the first version any direct manipulation is disabled, reenable in the future
    EditOverlay {
        id: editOverlay
        z: 999
    }
*/
    PlasmaCore.ColorScope {
        id: initialScreen

        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        Flickable {
            id: appletsView
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                property int extraMargin: root.smallScreenMode ? 0 : Kirigami.Units.largeSpacing
                topMargin: mainStack.topPadding + extraMargin
                leftMargin: mainStack.leftPadding + extraMargin
                rightMargin: mainStack.rightPadding + extraMargin
            }
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            height: root.smallScreenMode ? parent.height : parent.height / 3
            contentHeight: height
            contentWidth: appletsSpace.width
            AppletsArea {
                id: appletsSpace
                height: parent.height
            }
        }

        Loader {
            id: dashbardView
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: mainStack.leftPadding + extraMargin
                bottomMargin: mainStack.bottomMargin + extraMargin
                rightMargin: mainStack.rightPadding + extraMargin
            }
            height: (parent.height / 3) * 2
            active: !root.smallScreenMode
            source: Qt.resolvedUrl("./mycroft/Dashboard.qml")
        }
    }

    Mycroft.SkillView {
        id: mainStack
        anchors.fill: parent

        topPadding: plasmoid.availableScreenRect.y
        bottomPadding: root.height - plasmoid.availableScreenRect.y - plasmoid.availableScreenRect.height
        leftPadding: plasmoid.availableScreenRect.x
        rightPadding: root.width - plasmoid.availableScreenRect.x - plasmoid.availableScreenRect.width

        initialItem: initialScreen
        popEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        popExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: 0
                    to: height/4
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
            }
        }

        pushEnter: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/4
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic 
                }
            }
        }

        pushExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InCubic 
            }
        }
        replaceEnter: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/4
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic 
                }
            }
        }

        replaceExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: 0
                    to: -height/4
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
            }
        }
    }

    Mycroft.StatusIndicator {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.largeSpacing * 2
        }
    }
}
