/***************************************************************************
 *   Copyright (C) 2018 Marco Martin <mart@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "mycroftpanel.h"

#include <QDebug>
#include <QProcess>

MycroftPanel::MycroftPanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    //setHasConfigurationInterface(true);
}

MycroftPanel::~MycroftPanel()
{
}

void MycroftPanel::executeCommand(const QString &command)
{
    qWarning()<<"Executing"<<command;
    QProcess::startDetached(command);
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(quicksettings, MycroftPanel, "metadata.json")

#include "mycroftpanel.moc"
