/*
 *   Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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
    SettingPropertyKey(QString, webSocketAddress, setWebSocketAddress, webSocketChanged, "webSocketAddress", "ws://0.0.0.0")
#else
    SettingPropertyKey(QString, webSocketAddress, setWebSocketAddress, webSocketChanged, "webSocketAddress", "ws://46.101.212.234")
#endif
    QSettings _settings;
    
signals:
    void webSocketChanged();

};

#endif // GLOBALSETTINGS_H
