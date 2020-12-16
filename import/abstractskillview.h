/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
 * Copyright 2018 David Edmundson <davidedmundson@kde.org>
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

#include "mycroftcontroller.h"

#include <QQuickItem>
#include <QPointer>

class ActiveSkillsModel;
class AbstractSkillView;
class AbstractDelegate;
class SessionDataMap;
class QTranslator;

class AbstractSkillView: public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(MycroftController::Status status READ status NOTIFY statusChanged)

    Q_PROPERTY(ActiveSkillsModel *activeSkills READ activeSkills CONSTANT)

public:
    enum CustomFocusReasons {
        ServerEventFocusReason = Qt::OtherFocusReason
    };

    AbstractSkillView(QQuickItem *parent = nullptr);
    ~AbstractSkillView();

    MycroftController::Status status() const;

    ActiveSkillsModel *activeSkills() const;


    //API for MycroftController, NOT QML
    /**
     * Url of the Web socket
     */
    QUrl url() const;

    /**
     * Sets the url for the web socket
     */
    void setUrl(const QUrl &url);

    /**
     * Unique identifier for this GUI
     */
    QString id() const;

    /**
     * @internal triggers an event: invoked by the c++ side of the delegates via AbstractDelegate::triggerEvent
     */
    void triggerEvent(const QString &skillId, const QString &eventName, const QVariantMap &parameters);

    /**
     * @returns the property map that contains the data for a given skill,
     * if no data is present for a skill, it gets created if and only if it's an active skill.
     * @internal this is strictly for internal use only and must *NOT* be exposed to QML. used by the class itself and the autotests.
     */
    SessionDataMap *sessionDataForSkill(const QString &skillId);

    void writeProperties(const QString &skillId, const QVariantMap &data);
    void deleteProperty(const QString &skillId, const QString &property);

Q_SIGNALS:
    /**
     * The skill that was open due voice interaction has been closed either due to timeout or user interaction
     */
    void activeSkillClosed();
    //socket stuff
    void statusChanged();
    void closed();

private:
    void onGuiSocketMessageReceived(const QString &message);

    QTimer m_reconnectTimer;
    QTimer m_trimComponentsTimer;
    QString m_id;
    QUrl m_url;
    QHash<QString, SessionDataMap *> m_skillData;
    QHash<QString, QTranslator *> m_translatorsForSkill;

    MycroftController *m_controller;
    QWebSocket *m_guiWebSocket;
    ActiveSkillsModel *m_activeSkillsModel;
};

