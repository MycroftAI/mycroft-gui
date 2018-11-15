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

#include "mycroftcontroller.h"
#include "globalsettings.h"
#include "delegate.h"
#include "activeskillsmodel.h"
#include "abstractskillview.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>
#include <QProcess>
#include <QQmlPropertyMap>
#include <QStandardItemModel>
#include <QQmlEngine>
#include <QQmlContext>
#include <QUuid>
#include <QWebSocket>


MycroftController *MycroftController::instance()
{
    static MycroftController* s_self = nullptr;
    if (!s_self) {
        s_self = new MycroftController;
    }
    return s_self;
}


MycroftController::MycroftController(QObject *parent)
    : QObject(parent),
      m_appSettingObj(new GlobalSettings)
{
    connect(&m_mainWebSocket, &QWebSocket::connected, this,
            [this] () {
                m_reconnectTimer.stop();
                emit socketStatusChanged();
            });
    connect(&m_mainWebSocket, &QWebSocket::disconnected, this, &MycroftController::closed);
    connect(&m_mainWebSocket, &QWebSocket::stateChanged, this,
            [this] (QAbstractSocket::SocketState state) {
                emit socketStatusChanged();
                if (state == QAbstractSocket::ConnectedState) {
                    for (const auto &guiId : m_views.keys()) {
                        sendRequest(QStringLiteral("mycroft.gui.connected"),
                                    QVariantMap({{"gui_id", guiId}}));
                    }
                }
            });

    connect(&m_mainWebSocket, &QWebSocket::textMessageReceived, this, &MycroftController::onMainSocketMessageReceived);

    m_reconnectTimer.setInterval(1000);
    connect(&m_reconnectTimer, &QTimer::timeout, this, [this]() {
        QString socket = m_appSettingObj->webSocketAddress() + ":8181/core";
        m_mainWebSocket.open(QUrl(socket));
    });

#ifdef Q_OS_ANDROID
    m_speech = new QTextToSpeech(this);
#endif
}


void MycroftController::start()
{
    auto appSettingObj = new GlobalSettings;
    QString socket = m_appSettingObj->webSocketAddress() + ":8181/core";
    m_mainWebSocket.open(QUrl(socket));
    connect(&m_mainWebSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error),
            this, [this] (const QAbstractSocket::SocketError &error) {
        qDebug() << error;

        if (error != QAbstractSocket::HostNotFoundError && error != QAbstractSocket::ConnectionRefusedError) {
            qWarning("Mycroft is running but the connection failed for some reason. Kill Mycroft manually.");

            return;
        }

        QProcess::startDetached("mycroft-gui-core-loader");
        m_reconnectTimer.start();
        emit socketStatusChanged();
    });

    emit socketStatusChanged();
}

void MycroftController::reconnect()
{
    qDebug() << "in reconnect";
    m_mainWebSocket.close();
    m_reconnectTimer.start();
    emit socketStatusChanged();
}

void MycroftController::onMainSocketMessageReceived(const QString &message)
{
    auto doc = QJsonDocument::fromJson(message.toLatin1());

    auto type = doc["type"].toString();

    //filter out the noise so we can print debug stuff later without drowning in noise
    if (type.startsWith("enclosure") || type.startsWith("mycroft-date")) {
        return;
    }
    qDebug() << "type" << type;

    emit intentRecevied(type, doc["data"].toVariant().toMap());

#ifdef Q_OS_ANDROID
    if (type == "speak") {
        m_speech->say(doc["data"]["utterance"].toString());
    }
#endif

    if (type == QLatin1String("intent_failure")) {
        m_isListening = false;
        emit isListeningChanged();
        emit notUnderstood();
        return;
    }
    if (type == QLatin1String("recognizer_loop:audio_output_start")) {
        m_isSpeaking = true;
        emit isSpeakingChanged();
        return;
    }
    if (type == QLatin1String("recognizer_loop:audio_output_end")) {
        m_isSpeaking = false;
        emit isSpeakingChanged();
        return;
    }
    if (type == QLatin1String("recognizer_loop:record_begin")) {
        m_isListening = true;
        emit isListeningChanged();
        return;
    }
    if (type == QLatin1String("recognizer_loop:record_end")) {
        m_isListening = false;
        emit isListeningChanged();
        return;
    }
    if (type == QLatin1String("mycroft.speech.recognition.unknown")) {
        emit notUnderstood();
        return;
    }

    if (type == "mycroft.skill.handler.start") {
        m_currentSkill = doc["data"]["name"].toString();
        qDebug() << "Current skill:" << m_currentSkill;
        emit currentSkillChanged();
    } else if (type == "mycroft.skill.handler.complete") {
        m_currentSkill = QString();
        emit currentSkillChanged();
    } else if (type == "speak") {
        emit fallbackTextRecieved(m_currentSkill, doc["data"].toVariant().toMap());
    } else if (type == QLatin1String("mycroft.stop.handled") || type == QLatin1String("mycroft.stop")) {
        emit stopped();
    } else if (type == "mycroft.gui.port") {
        const int port = doc["data"]["port"].toInt();
        const QString guiId = doc["data"]["gui_id"].toString();
        if (port < 0) {
            qWarning() << "Invalid port from mycroft.gui.port";
            return;
        }

        if (!m_views.contains(guiId)) {
            qWarning() << "Unknown guiId from mycroft.gui.port";
            return;
        }

        QUrl url(QString("%1:%2/gui").arg(m_appSettingObj->webSocketAddress()).arg(port));
//FIXME
        url.setPort(port);
        m_views[guiId]->setUrl(url);
    }
}

void MycroftController::sendRequest(const QString &type, const QVariantMap &data)
{
    if (m_mainWebSocket.state() != QAbstractSocket::ConnectedState) {
        qWarning() << "mycroft connection not open!";
        return;
    }
    QJsonObject root;

    root["type"] = type;
    root["data"] = QJsonObject::fromVariantMap(data);

    QJsonDocument doc(root);
    m_mainWebSocket.sendTextMessage(doc.toJson());
}

void MycroftController::sendText(const QString &message)
{
    sendRequest(QStringLiteral("recognizer_loop:utterance"), QVariantMap({{"utterances", QStringList({message})}}));
}

void MycroftController::registerView(AbstractSkillView *view)
{
    Q_ASSERT(!view->id().isEmpty());
    Q_ASSERT(!m_views.contains(view->id()));
    m_views[view->id()] = view;
//TODO: manage view destruction
    if (m_mainWebSocket.state() == QAbstractSocket::ConnectedState) {
        sendRequest(QStringLiteral("mycroft.gui.connected"),
                    QVariantMap({{"gui_id", view->id()}}));
    }
}

MycroftController::Status MycroftController::status() const
{
    if (m_reconnectTimer.isActive()) {
        return Connecting;
    }

    switch(m_mainWebSocket.state())
    {
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::BoundState:
    case QAbstractSocket::HostLookupState:
        return Connecting;
    case QAbstractSocket::UnconnectedState:
        return Closed;
    case QAbstractSocket::ConnectedState:
        return Open;
    case QAbstractSocket::ClosingState:
        return Closing;
    default:
        return Connecting;
    }
}

//FIXME: remove
QString MycroftController::currentSkill() const
{
    return m_currentSkill;
}

bool MycroftController::isSpeaking() const
{
    return m_isSpeaking;
}

bool MycroftController::isListening() const
{
    return m_isListening;
}

#include "moc_mycroftcontroller.cpp"
