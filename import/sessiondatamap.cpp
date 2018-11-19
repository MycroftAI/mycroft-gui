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
