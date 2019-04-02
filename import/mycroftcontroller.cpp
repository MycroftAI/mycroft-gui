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

#include "mycroftcontroller.h"
#include "globalsettings.h"
#include "abstractdelegate.h"
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
                    qWarning() << "Main Socket connected, trying to connect gui";
                    for (const auto &guiId : m_views.keys()) {
                        sendRequest(QStringLiteral("mycroft.gui.connected"),
                                    QVariantMap({{QStringLiteral("gui_id"), guiId}}));
                    }
                    m_reannounceGuiTimer.start();
                }
            });

    connect(&m_mainWebSocket, &QWebSocket::textMessageReceived, this, &MycroftController::onMainSocketMessageReceived);

    m_reconnectTimer.setInterval(1000);
    connect(&m_reconnectTimer, &QTimer::timeout, this, [this]() {
        QString socket = m_appSettingObj->webSocketAddress() + QStringLiteral(":8181/core");
        m_mainWebSocket.open(QUrl(socket));
    });

    m_reannounceGuiTimer.setInterval(10000);
    connect(&m_reannounceGuiTimer, &QTimer::timeout, this, [this]() {
        if (m_mainWebSocket.state() != QAbstractSocket::ConnectedState) {
            return;
        }
        for (const auto &guiId : m_views.keys()) {
            if (m_views[guiId]->status() != Open) {
                qWarning()<<"Retrying to announce gui";
                sendRequest(QStringLiteral("mycroft.gui.connected"),
                            QVariantMap({{QStringLiteral("gui_id"), guiId}}));
            }
        }
    });

#ifdef Q_OS_ANDROID
    m_speech = new QTextToSpeech(this);
#endif
}


void MycroftController::start()
{
    auto appSettingObj = new GlobalSettings;
    QString socket = m_appSettingObj->webSocketAddress() + QStringLiteral(":8181/core");
    m_mainWebSocket.open(QUrl(socket));
    connect(&m_mainWebSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error),
            this, [this] (const QAbstractSocket::SocketError &error) {
        qDebug() << error;

        if (error != QAbstractSocket::HostNotFoundError && error != QAbstractSocket::ConnectionRefusedError) {
            qWarning("Mycroft is running but the connection failed for some reason. Kill Mycroft manually.");

            return;
        }

        //don't try to launch mycroft more than once
        if (!m_mycroftLaunched) {
            QProcess::startDetached(QStringLiteral("mycroft-gui-core-loader"));
            m_mycroftLaunched = true;
        }
        m_reconnectTimer.start();
        emit socketStatusChanged();
    });

    emit socketStatusChanged();
}

void MycroftController::disconnectSocket()
{
    qDebug() << "in reconnect";
    m_mainWebSocket.close();
    m_reconnectTimer.stop();
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
    auto doc = QJsonDocument::fromJson(message.toUtf8());

    if (doc.isEmpty()) {
        qWarning() << "Empty or invalid JSON message arrived on the main socket:" << message;
        return;
    }

    auto type = doc[QStringLiteral("type")].toString();

    if (type.isEmpty()) {
        qWarning() << "Empty type in the JSON message on the main socket";
        return;
    }

    //filter out the noise so we can print debug stuff later without drowning in noise
    if (type.startsWith(QStringLiteral("enclosure")) || type.startsWith(QStringLiteral("mycroft-date"))) {
        return;
    }

#ifdef DEBUG_MYCROFT_MESSAGEBUS
    qDebug() << "type" << type;
#endif

    emit intentRecevied(type, doc[QStringLiteral("data")].toVariant().toMap());

#ifdef Q_OS_ANDROID
    if (type == QLatin1String("speak")) {
        m_speech->say(doc[QStringLiteral("data")]["utterance"].toString());
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

    if (type == QLatin1String("mycroft.skill.handler.start")) {
        m_currentSkill = doc[QStringLiteral("data")][QStringLiteral("name")].toString();
        qDebug() << "Current skill:" << m_currentSkill;
        emit currentSkillChanged();
    } else if (type == QLatin1String("mycroft.skill.handler.complete")) {
        m_currentSkill = QString();
        emit currentSkillChanged();
    } else if (type == QLatin1String("speak")) {
        emit fallbackTextRecieved(m_currentSkill, doc[QStringLiteral("data")].toVariant().toMap());
    } else if (type == QLatin1String("mycroft.stop.handled") || type == QLatin1String("mycroft.stop")) {
        emit stopped();

    } else if (type == QLatin1String("mycroft.gui.port")) {
        const int port = doc[QStringLiteral("data")][QStringLiteral("port")].toInt();
        const QString guiId = doc[QStringLiteral("data")][QStringLiteral("gui_id")].toString();
        if (port < 0 || port > 65535) {
            qWarning() << "Invalid port from mycroft.gui.port";
            return;
        }

        qWarning() << "Received port" << port << "for gui" << guiId;
        if (!m_views.contains(guiId)) {
            qWarning() << "Unknown guiId from mycroft.gui.port";
            return;
        }

        QUrl url(QStringLiteral("%1:%2/gui").arg(m_appSettingObj->webSocketAddress()).arg(port));
        m_views[guiId]->setUrl(url);
        m_reannounceGuiTimer.stop();
    }
}

void MycroftController::sendRequest(const QString &type, const QVariantMap &data)
{
    if (m_mainWebSocket.state() != QAbstractSocket::ConnectedState) {
        qWarning() << "mycroft connection not open!";
        return;
    }
    QJsonObject root;

    root[QStringLiteral("type")] = type;
    root[QStringLiteral("data")] = QJsonObject::fromVariantMap(data);

    QJsonDocument doc(root);
    m_mainWebSocket.sendTextMessage(QString::fromUtf8(doc.toJson()));
}

void MycroftController::sendText(const QString &message)
{
    sendRequest(QStringLiteral("recognizer_loop:utterance"), QVariantMap({{QStringLiteral("utterances"), QStringList({message})}}));
}

void MycroftController::registerView(AbstractSkillView *view)
{
    Q_ASSERT(!view->id().isEmpty());
    Q_ASSERT(!m_views.contains(view->id()));
    m_views[view->id()] = view;
//TODO: manage view destruction
    if (m_mainWebSocket.state() == QAbstractSocket::ConnectedState) {
        sendRequest(QStringLiteral("mycroft.gui.connected"),
                    QVariantMap({{QStringLiteral("gui_id"), view->id()}}));
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
