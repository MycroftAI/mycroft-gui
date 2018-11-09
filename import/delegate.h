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

class MycroftController;

class Delegate: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlPropertyMap *sessionData READ sessionData CONSTANT)
    Q_PROPERTY(int timeout MEMBER m_timeout NOTIFY timeoutChanged)
    //TODO: api for background? would like to avoid
public:
    Delegate(QObject *parent = nullptr);
    ~Delegate();

    //API used only by MycroftController, *NOT* QML
    //void setController(MycroftController *controller);
    //void setSkillId();
    void setSessionData(QQmlPropertyMap *data);
    QQmlPropertyMap *sessionData() const;

Q_SIGNALS:
    void timeoutChanged();
    void leftPaddingChanged();
    void rightPaddingChanged();
    void topPaddingChanged();
    void bottomPaddingChanged();

private:
    QPointer<QQmlPropertyMap> m_data;

    int m_timeout = 5000; //Completely arbitrary 5 seconds of timeout
};

