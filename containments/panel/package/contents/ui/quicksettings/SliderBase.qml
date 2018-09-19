/*
 *   Copyright 2018 Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <<davidedmundson@kde.org>>
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

RowLayout {
    spacing: Kirigami.Units.smallSpacing
    property alias leftIconSource: leftIcon.source
    property alias rightIconSource: rightIcon.source
    property alias slider: slider

    Kirigami.Icon {
        id: leftIcon
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Layout.preferredWidth
    }
    Controls.Slider {
        id: slider
        Layout.fillWidth: true
    }
    Kirigami.Icon {
        id: rightIcon
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Layout.preferredWidth
    }
}
