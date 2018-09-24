/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.kirigami 2.5 as Kirigami

Rectangle {
    id: taskIcon

    color: Kirigami.Theme.backgroundColor

    visible: tasksModel.activeTask.valid

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        filterByScreen: plasmoid.configuration.showForCurrentScreenOnly

    }
    Controls.Label {
        anchors.centerIn: parent
        text: tasksModel.data(tasksModel.activeTask, TaskManager.TasksModel.AppName) || ""
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)

        function exec(cmd) {
            executable.connectSource(cmd)
        }
    }

    Controls.ToolButton {
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: height
        icon.name: "view-grid-symbolic"
        onClicked: executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ExposeAll"')
    }

    Controls.ToolButton {
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        width: height
        icon.name: "window-close"
        onClicked: tasksModel.requestClose(tasksModel.activeTask)
    }
}
