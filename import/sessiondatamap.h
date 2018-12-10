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

#pragma once

#include <QQmlPropertyMap>

class QTimer;
class AbstractSkillView;

class SessionDataMap : public QQmlPropertyMap
{
    Q_OBJECT

public:
    SessionDataMap(const QString &skillId, AbstractSkillView *parent);
    ~SessionDataMap() override;

    /**
     * Like insert, but will emit the valueChanged() signal
     */
    void insertAndNotify(const QString &key, const QVariant &value);

    /**
     * Like clear(), but will emit the dataCleared() signal
     */
    void clearAndNotify(const QString &key);

Q_SIGNALS:
    /**
     * Key has been removed fro the map
     */
    void dataCleared(const QString &key);

protected:
    QVariant updateValue(const QString &key, const QVariant &input) override;

private:
    QString m_skillId;
    QVariantMap m_propertiesToUpdate;
    QStringList m_propertiesToDelete;
    QTimer *m_updateTimer;
    AbstractSkillView *m_view;
};

