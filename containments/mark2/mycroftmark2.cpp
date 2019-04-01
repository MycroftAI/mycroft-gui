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

#include "mycroftmark2.h"

#include <QDebug>
#include <QProcess>

#include <kworkspace5/kdisplaymanager.h>

MycroftMark2::MycroftMark2(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    //setHasConfigurationInterface(true);
}

MycroftMark2::~MycroftMark2()
{
}

void MycroftMark2::executeCommand(const QString &command)
{
    qWarning()<<"Executing"<<command;
    QProcess::startDetached(command);
}

void MycroftMark2::requestShutdown()
{
    KWorkSpace::requestShutDown(KWorkSpace::ShutdownConfirmDefault, KWorkSpace::ShutdownTypeHalt);
}

void MycroftMark2::requestReboot()
{
    KWorkSpace::requestShutDown(KWorkSpace::ShutdownConfirmDefault, KWorkSpace::ShutdownTypeReboot);
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(quicksettings, MycroftMark2, "metadata.json")

#include "mycroftmark2.moc"
