/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <davidedmundson@kde.org>
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

#include <QObject>
#include <QWebSocket>
#include <QPointer>
#include <QQuickItem>

#ifdef Q_OS_ANDROID
#include <QTextToSpeech>
#endif

#include <QTimer>

class GlobalSettings;
class QQmlPropertyMap;
class ActiveSkillsModel;
class Delegate;

class MycroftController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status NOTIFY socketStatusChanged)
    //FIXME: make those two enums?
    Q_PROPERTY(bool speaking READ isSpeaking NOTIFY isSpeakingChanged)
    Q_PROPERTY(bool listening READ isListening NOTIFY isListeningChanged)
    //FIXME: to remove?
    Q_PROPERTY(QString currentSkill READ currentSkill NOTIFY currentSkillChanged)

    Q_PROPERTY(ActiveSkillsModel *activeSkills READ activeSkills CONSTANT)

    Q_ENUMS(Status)
public:
    enum Status {
        Connecting,
        Open,
        Closing,
        Closed,
        Error
    };
    static MycroftController* instance();

    bool isSpeaking() const;
    bool isListening() const;
    Status status() const;
    QString currentSkill() const;

    ActiveSkillsModel *activeSkills() const;

Q_SIGNALS:
    //socket stuff
    void socketStatusChanged();
    void closed();

    //mycroft
    void isSpeakingChanged();
    void isListeningChanged();
    void stopped();
    void notUnderstood();
    void currentSkillChanged();

    //signal with nearly all data
    //TODO: remove?
    void intentRecevied(const QString &type, const QVariantMap &data);

    //type utterances, type is the current skill
    //TODO: remove?
    void fallbackTextRecieved(const QString &skill, const QVariantMap &data);

    //NEW API:
    //TODO: remove the signal, make the gui part of the gui model
    void skillGuiCreated(const QString &skillId, QQuickItem *gui);
    void eventTriggered(const QString &eventString, const QVariantMap &parameters);

public Q_SLOTS:
    void start();
    void reconnect();
    void sendRequest(const QString &type, const QVariantMap &data);
    void sendGuiRequest(const QString &type, const QVariantMap &data);
    void sendText(const QString &message);
    void triggerEvent(const QString &eventId, const QVariantMap &parameters);
    void registerGui(QQuickItem *gui);

private:
    explicit MycroftController(QObject *parent = nullptr);
    QQmlPropertyMap *sessionDataForSkill(const QString &skillId);
    void onMainSocketMessageReceived(const QString &message);
    void onGuiSocketMessageReceived(const QString &message);


    QWebSocket m_mainWebSocket;
    QWebSocket m_guiWebSocket;

    QTimer m_reconnectTimer;
    GlobalSettings *m_appSettingObj;

    //TODO: remove
    QString m_currentSkill;
    QString m_guiId;

    ActiveSkillsModel *m_activeSkillsModel;
    QHash<QString, QQmlPropertyMap*> m_skillData;
    //TODO: move it in activeskillsmodel
    QHash<QString, QHash<QUrl, QQuickItem *> > m_guis;
    
    QPointer<QQuickItem> m_gui;

#ifdef Q_OS_ANDROID
    QTextToSpeech *m_speech;
#endif

    bool m_isSpeaking = false;
    bool m_isListening = false;
};

