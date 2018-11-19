/*
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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

#ifndef GLOBALSETTINGS_H
#define GLOBALSETTINGS_H

#include <QSettings>
#include <QCoreApplication>
#include <QDebug>

#define SettingPropertyKey(type, name, setOption, signalName, settingKey, defaultValue) \
    inline type name() const { return _settings.value(settingKey, defaultValue).value<type>(); } \
    inline void setOption (const type &value) { _settings.setValue(settingKey, value); emit signalName(); qDebug() << "emitted"; }

class QSettings;
class GlobalSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString webSocketAddress READ webSocketAddress WRITE setWebSocketAddress NOTIFY webSocketChanged)
    
public:
    explicit GlobalSettings(QObject *parent=0);
#ifndef Q_OS_ANDROID
    SettingPropertyKey(QString, webSocketAddress, setWebSocketAddress, webSocketChanged, QStringLiteral("webSocketAddress"), QStringLiteral("ws://0.0.0.0"))
#else
    SettingPropertyKey(QString, webSocketAddress, setWebSocketAddress, webSocketChanged, QStringLiteral("webSocketAddress"), QStringLiteral("ws://46.101.212.234"))
#endif
    QSettings _settings;
    
signals:
    void webSocketChanged();

};

#endif // GLOBALSETTINGS_H
