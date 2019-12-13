/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
 * Copyright 2018 David Edmundson <davidedmundson@kde.org>
 * Copyright 2018 Aditya Mehra <aix.m@outlook.com>
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

#include "mycroftplugin.h"

#include "mycroftcontroller.h"
#include "globalsettings.h"
#include "filereader.h"
#include "abstractdelegate.h"
#include "abstractskillview.h"
#include "activeskillsmodel.h"
#include "delegatesmodel.h"
#include "sessiondatamap.h"
#include "audiorec.h"

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
    Q_UNUSED(scriptEngine);

    //singleton managed internally, qml should never delete it
    engine->setObjectOwnership(MycroftController::instance(), QQmlEngine::CppOwnership);
    return MycroftController::instance();
}

void MycroftPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("Mycroft"));

    qmlRegisterSingletonType<MycroftController>(uri, 1, 0, "MycroftController", mycroftControllerSingletonProvider);
    qmlRegisterSingletonType<GlobalSettings>(uri, 1, 0, "GlobalSettings", globalSettingsSingletonProvider);
    qmlRegisterSingletonType<FileReader>(uri, 1, 0, "FileReader", fileReaderSingletonProvider);
    qmlRegisterType<AbstractSkillView>(uri, 1, 0, "AbstractSkillView");
    qmlRegisterType<AbstractDelegate>(uri, 1, 0, "AbstractDelegate");
    qmlRegisterType<AudioRec>(uri, 1, 0, "AudioRec");

    qmlRegisterUncreatableType<ActiveSkillsModel>(uri, 1, 0, "ActiveSkillsModel", QStringLiteral("You cannot instantiate items of type ActiveSkillsModel"));
    qmlRegisterUncreatableType<ActiveSkillsFilterModel>(uri, 1, 0, "ActiveSkillsFilterModel", QStringLiteral("You cannot instantiate items of type ActiveSkillsFilterModel"));
    qmlRegisterUncreatableType<DelegatesModel>(uri, 1, 0, "DelegatesModel", QStringLiteral("You cannot instantiate items of type DelegatesModel"));
    qmlRegisterUncreatableType<SessionDataMap>(uri, 1, 0, "SessionDataMap", QStringLiteral("You cannot instantiate items of type SessionDataMap"));

    //use this only when all qml files are registered by the plugin
   // qmlProtectModule(uri, 1);
}

#include "moc_mycroftplugin.cpp"

