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
#include "abstractskillview.h"
#include "sessiondatamodel.h"

#include <QDebug>
#include <QJSValue>
#include <cstddef>

SessionDataMap::SessionDataMap(const QString &skillId, AbstractSkillView *parent)
    : QQmlPropertyMap(this, parent),
      m_skillId(skillId),
      m_view(parent)
{
    m_updateTimer = new QTimer(this);
    m_updateTimer->setSingleShot(true);
    m_updateTimer->setInterval(250); //arbitrary
    connect(m_updateTimer, &QTimer::timeout, this, [this]() {
        if (!m_propertiesToUpdate.isEmpty()) {
            m_view->writeProperties(m_skillId, m_propertiesToUpdate);
        }
        for (auto k : m_propertiesToDelete) {
            m_view->deleteProperty(m_skillId, k);
        }
        m_propertiesToUpdate.clear();
        m_propertiesToDelete.clear();
    });
}

SessionDataMap::~SessionDataMap()
{
}

QVariant SessionDataMap::updateValue(const QString &key, const QVariant &newValue)
{
    if (value(key).canConvert<SessionDataModel *>()) {
        qWarning() << "Can't replace a model from the client side";
        return value(key);
    }

    if (newValue.isNull() || !newValue.isValid() ) {
        m_propertiesToDelete << key;
    } else {
        m_propertiesToUpdate[key] = newValue;
    }

    m_updateTimer->start();

    return QQmlPropertyMap::updateValue(key, newValue);
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
