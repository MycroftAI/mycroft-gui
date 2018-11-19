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
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.kirigami 2.5 as Kirigami

Rectangle {
    id: taskIcon

    color: Kirigami.Theme.backgroundColor

    visible: tasksModel.activeTask.valid && !tasksModel.data(tasksModel.activeTask, TaskManager.AbstractTasksModel.IsFullScreen)

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        filterByScreen: plasmoid.configuration.showForCurrentScreenOnly

    }
    Controls.Label {
        anchors.centerIn: parent
        text: tasksModel.data(tasksModel.activeTask, TaskManager.AbstractTasksModel.AppName) || ""
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
