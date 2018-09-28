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
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>
#include <QProcess>

MycroftController *MycroftController::instance()
{
    static MycroftController* s_self = nullptr;
    if (!s_self) {
        s_self = new MycroftController;
    }
    return s_self;
}


MycroftController::MycroftController(QObject *parent): QObject(parent)
{
    connect(&m_webSocket, &QWebSocket::connected, this, &MycroftController::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected, this, &MycroftController::closed);
    connect(&m_webSocket, &QWebSocket::stateChanged, this, &MycroftController::onStatusChanged);
    connect(&m_webSocket, &QWebSocket::textMessageReceived, this, &MycroftController::onTextMessageReceived);

    m_reconnectTimer.setInterval(1000);
    connect(&m_reconnectTimer, &QTimer::timeout, this, [this]() {
        QString socket = qgetenv("MYCROFT_SOCKET");
        if (socket.isEmpty()) {
            socket = "ws://0.0.0.0:8181/core";
        }
        m_webSocket.open(QUrl(socket));
    });
}


void MycroftController::start()
{
    QProcess::startDetached("mycroft-gui-core-loader");
    m_reconnectTimer.start();
    emit socketStatusChanged();
}

void MycroftController::onConnected()
{
    m_reconnectTimer.stop();
    emit socketStatusChanged();
}

void MycroftController::onTextMessageReceived(const QString &message)
{
    auto doc = QJsonDocument::fromJson(message.toLatin1());

    auto type = doc["type"].toString();


    //filter out the noise so we can print debug stuff later without drowning in noise
    if (type.startsWith("enclosure") || type.startsWith("mycroft-date")) {
        return;
    }
    qDebug() << "type" << type;

    emit intentRecevied(type, doc["data"].toVariant().toMap());

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
        emit currentSkillChanged();
    } else if (type == "mycroft.skill.handler.complete") {
        m_currentSkill = QString();
        emit currentSkillChanged();
    } else if (type == "speak") {
        emit fallbackTextRecieved(m_currentSkill, doc["data"].toVariant().toMap());
    } else if (type == QLatin1String("mycroft.stop.handled") || type == QLatin1String("mycroft.stop")) {
        emit stopped();
    }
    else if (type == "metadata") {
        emit skillDataRecieved(doc["data"].toVariant().toMap());
    }
}

void MycroftController::sendRequest(const QString &type, const QVariantMap &data)
{
    if (m_webSocket.state() != QAbstractSocket::ConnectedState) {
        qWarning() << "mycroft connection not open!";
        return;
    }
    QJsonObject root;

    root["type"] = type;
    root["data"] = QJsonObject::fromVariantMap(data);

    QJsonDocument doc(root);
    m_webSocket.sendTextMessage(doc.toJson());
}

void MycroftController::sendText(const QString &message)
{
    sendRequest(QStringLiteral("recognizer_loop:utterance"), QVariantMap({{"utterances", QStringList({message})}}));
}


void MycroftController::onStatusChanged(QAbstractSocket::SocketState state)
{
    emit socketStatusChanged();
    //qDebug() << "State changed to " << status();
}

MycroftController::Status MycroftController::status() const
{
    if (m_reconnectTimer.isActive()) {
        return Connecting;
    }

    switch(m_webSocket.state())
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

