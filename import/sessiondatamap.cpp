/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
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

#include "sessiondatamap.h"

#include <QDebug>
#include <QJSValue>

SessionDataMap::SessionDataMap(QObject *parent)
    : QQmlPropertyMap(this, parent)
{
}

SessionDataMap::~SessionDataMap()
{
}

QVariant SessionDataMap::updateValue(const QString &key, const QVariant &input)
{
    //TODO: send modifications to the server, filter models etc
    return QQmlPropertyMap::updateValue(key, input);
}

void SessionDataMap::insertAndNotify(const QString &key, const QVariant &value)
{
    insert(key, value);
    emit valueChanged(key, value);
}

void SessionDataMap::clearAndNotify(const QString &key)
{
    clear(key);
    emit dataCleared(key);
}

#include "moc_sessiondatamap.cpp"
