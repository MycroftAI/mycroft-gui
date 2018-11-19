/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
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

#include "abstractdelegate.h"
#include "mycroftcontroller.h"

AbstractDelegate::AbstractDelegate(QQuickItem *parent)
    : QQuickItem(parent)
{
}

AbstractDelegate::~AbstractDelegate()
{
}

void AbstractDelegate::setSessionData(SessionDataMap *data)
{
    //possible to call only once, by the skillview upon instantiation
    Q_ASSERT(!m_data);
    m_data = data;
}

SessionDataMap *AbstractDelegate::sessionData() const
{
    return m_data;
}

void AbstractDelegate::setQmlUrl(const QUrl &url)
{
    Q_ASSERT(m_qmlUrl.isEmpty());
    m_qmlUrl = url;
}

QUrl AbstractDelegate::qmlUrl() const
{
    return m_qmlUrl;
}

void AbstractDelegate::setSkillId(const QString &skillId)
{
    Q_ASSERT(m_skillId.isEmpty());
    m_skillId = skillId;
}

QString AbstractDelegate::skillId() const
{
    return m_skillId;
}

#include "moc_abstractdelegate.cpp"
