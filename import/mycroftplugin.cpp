/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <davidedmundson@kde.org>
 *   Copyright 2018 Aditya Mehra <aix.m@outlook.com>
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

#include "mycroftplugin.h"

#include "mycroftcontroller.h"
#include "globalsettings.h"
#include "filereader.h"
#include "delegate.h"
#include "abstractskillview.h"

#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>

static QObject *fileReaderSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    
    return new FileReader;
}

static QObject *globalSettingsSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new GlobalSettings;
}

static QObject *mycroftControllerSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return MycroftController::instance();
}

void MycroftPlugin::registerTypes(const char *uri)
{
    //TODO: org.kde.mycroft?
    Q_ASSERT(uri == QLatin1String("Mycroft"));

    qmlRegisterSingletonType<MycroftController>(uri, 1, 0, "MycroftController", mycroftControllerSingletonProvider);
    qmlRegisterSingletonType<GlobalSettings>(uri, 1, 0, "GlobalSettings", globalSettingsSingletonProvider);
    qmlRegisterSingletonType<FileReader>(uri, 1, 0, "FileReader", fileReaderSingletonProvider);
    qmlRegisterType<AbstractSkillView>(uri, 1, 0, "AbstractSkillView");
    qmlRegisterType<Delegate>(uri, 1, 0, "Delegate");

    //use this only when all qml files are registered by the plugin
   // qmlProtectModule(uri, 1);
}

#include "moc_mycroftplugin.cpp"

