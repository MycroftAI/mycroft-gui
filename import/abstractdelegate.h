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

#include <QQuickItem>

#include <QQmlPropertyMap>
#include <QPointer>

#include "sessiondatamap.h"

class MycroftController;

class AbstractDelegate: public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(SessionDataMap *sessionData READ sessionData CONSTANT)
    Q_PROPERTY(int timeout MEMBER m_timeout NOTIFY timeoutChanged)

    //TODO: api for background? would like to avoid
    Q_PROPERTY(int leftPadding MEMBER m_leftPadding NOTIFY leftPaddingChanged)
    Q_PROPERTY(int rightPadding MEMBER m_rightPadding NOTIFY rightPaddingChanged)
    Q_PROPERTY(int topPadding MEMBER m_topPadding NOTIFY topPaddingChanged)
    Q_PROPERTY(int bottomPadding MEMBER m_bottomPadding NOTIFY bottomPaddingChanged)

public:
    AbstractDelegate(QQuickItem *parent = nullptr);
    ~AbstractDelegate();

    //API used only by AbstractSkillView during initialization, *NOT* QML
    //void setController(MycroftController *controller);
    void setSessionData(SessionDataMap *data);
    SessionDataMap *sessionData() const;

    /**
     * INTERNAL: Url of the qml file that generated this instance
     */
    void setQmlUrl(const QUrl &url);
    QUrl qmlUrl() const;

    /**
     * @internal skill id this delegate belongs to
     */
    void setSkillId(const QString &skillId);
    QString skillId() const;

Q_SIGNALS:
    /**
     * Emitted when the delegate asks to be the "current" in the view
     *TODO: maybe abuse focus instead?
     */
    void currentRequested();

    /**
     * Emitted when the server triggered an event.
     * It is guaranteed the event will be either a system event or an event belonging to our skill, but never to another skill
     * @param eventName the unique name for the event
     * @param data the data for this event in JSon form
     */
    void event(const QString &eventName, const QVariantMap &data);

    //QML property notifiers
    void timeoutChanged();
    void leftPaddingChanged();
    void rightPaddingChanged();
    void topPaddingChanged();
    void bottomPaddingChanged();

private:
    QPointer<SessionDataMap> m_data;

    QUrl m_qmlUrl;
    QString m_skillId;

    int m_timeout = 5000; //Completely arbitrary 5 seconds of timeout

    int m_leftPadding = 0; //FIXME: how to bind to kirigami units from c++?
    int m_rightPadding = 0;
    int m_topPadding = 0;
    int m_bottomPadding = 0;
};

