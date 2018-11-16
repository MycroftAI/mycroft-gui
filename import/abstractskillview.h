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

#pragma once

#include "mycroftcontroller.h"

#include <QQuickItem>
#include <QPointer>

class ActiveSkillsModel;
class AbstractDelegate;
class SessionDataMap;

class AbstractSkillView: public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(MycroftController::Status status READ status NOTIFY statusChanged)

    Q_PROPERTY(ActiveSkillsModel *activeSkills READ activeSkills CONSTANT)

public:
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
     * @returns the property map that contains the data for a given skill,
     * if no data is present for a skill, it gets created if and only if it's an active skill.
     * @internal this is strictly for internal use only and must *NOT* be exposed to QML. used by the class itself and the autotests.
     */
    SessionDataMap *sessionDataForSkill(const QString &skillId);

Q_SIGNALS:
    //socket stuff
    void statusChanged();
    void closed();

private:
    void onGuiSocketMessageReceived(const QString &message);

    QTimer m_reconnectTimer;
    QString m_id;
    QUrl m_url;
    QHash<QString, SessionDataMap*> m_skillData;

    MycroftController *m_controller;
    QWebSocket *m_guiWebSocket;
    ActiveSkillsModel *m_activeSkillsModel;
};

