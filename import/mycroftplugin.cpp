/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>

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
#include "skillloader.h"

#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>


static QObject *mycroftControllerSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new MycroftController;
}

void MycroftPlugin::registerTypes(const char *uri)
{
    //TODO: org.kde.mycroft?
    Q_ASSERT(uri == QLatin1String("Mycroft"));

    qmlRegisterSingletonType<MycroftController>(uri, 1, 0, "MycroftController", mycroftControllerSingletonProvider);

    qmlRegisterType<SkillLoader>(uri, 1, 0, "SkillLoader");

    //use this only when all qml files are registered by the plugin
   // qmlProtectModule(uri, 1);
}

#include "moc_mycroftplugin.cpp"

