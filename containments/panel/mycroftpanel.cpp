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

#include "mycroftpanel.h"

#include <QDebug>
#include <QProcess>

#include <KWindowSystem>

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

void MycroftPanel::requestShowingDesktop()
{
    KWindowSystem::setShowingDesktop(true);
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(quicksettings, MycroftPanel, "metadata.json")

#include "mycroftpanel.moc"
