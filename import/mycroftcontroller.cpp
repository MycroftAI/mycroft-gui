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
#include "controllerconfig.h"

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
#include <QMediaPlayer>

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

                    sendRequest(QStringLiteral("mycroft.skills.all_loaded"), QVariantMap());
                } else {
                    if (m_serverReady) {
                        m_serverReady = false;
                        emit serverReadyChanged();
                    }
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
    connect(m_speech, &QTextToSpeech::stateChanged, this, [this] () {
        if (!ttsqueue.isEmpty() && m_speech->state() != QTextToSpeech::Speaking) {
            m_speech->say(ttsqueue.dequeue());
        }
        
        if (ttsqueue.isEmpty() && m_speech->state() != QTextToSpeech::Speaking && m_isExpectingSpeechResponse) {
            emit speechRequestedChanged(m_isExpectingSpeechResponse);
            m_isExpectingSpeechResponse = false;
        }
    });
#endif

}


void MycroftController::start()
{
    //auto appSettingObj = new GlobalSettings;
    QString socket = m_appSettingObj->webSocketAddress() + QStringLiteral(":8181/core");
    m_mainWebSocket.open(QUrl(socket));
    connect(&m_mainWebSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error),
            this, [this] (const QAbstractSocket::SocketError &error) {
        //qDebug() << error;

        if (error != QAbstractSocket::HostNotFoundError && error != QAbstractSocket::ConnectionRefusedError) {
            qWarning() << "Mycroft is running but the connection failed for some reason. Kill Mycroft manually.";

            return;
        }

        //don't try to launch mycroft more than once
        if (!m_mycroftLaunched) {
            QProcess::startDetached(QStringLiteral("mycroft-gui-core-loader"), QStringList());
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
    if (m_mycroftLaunched) {
        QProcess::startDetached(QStringLiteral("mycroft-gui-core-stop"), QStringList());
        m_mycroftLaunched = false;
    }
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
    if (type == QLatin1String("speak") && m_speech->state() != QTextToSpeech::Speaking) {
        m_speech->say(doc[QStringLiteral("data")][QStringLiteral("utterance")].toString());
    } else if (type == QLatin1String("speak") && m_speech->state() == QTextToSpeech::Speaking) {
        ttsqueue.enqueue(doc[QStringLiteral("data")][QStringLiteral("utterance")].toString());
    }
    
    if (type == QLatin1String("mycroft.mic.listen")) {
        m_isExpectingSpeechResponse = true;
    }
#endif

    if (type == QLatin1String("remote.tts.audio") && m_appSettingObj->usesRemoteTTS()) {
        QString aud = doc[QStringLiteral("data")][QStringLiteral("wave")].toString();
        auto innerdoc = QJsonDocument::fromJson(aud.toUtf8());
        QJsonValue qjv = innerdoc[QStringLiteral("py/b64")];
        QString aud_values = qjv.toString();
        QByteArray audioopt;
        audioopt.append(qUtf8Printable(aud_values));
        QByteArray aud_array = QByteArray::fromBase64(audioopt, QByteArray::Base64UrlEncoding);
        QByteArray ret_aud = QByteArray::fromBase64(aud_array);
        QFile file(QStringLiteral("/tmp/incoming.wav"));
        file.open(QIODevice::WriteOnly);
        file.write(ret_aud);
        file.close();
        QMediaPlayer *player = new QMediaPlayer;
        player->setMedia(QUrl::fromLocalFile(QStringLiteral("/tmp/incoming.wav")));
        player->play();
    }

    // Try catching intent_failure from another method because of issue: https://github.com/MycroftAI/mycroft-core/issues/2490
    if (type == QLatin1String("active_skill_request")) {         
        QString skill_id = doc[QStringLiteral("data")][QStringLiteral("skill_id")].toString();
        if (skill_id == QStringLiteral("fallback-unknown.mycroftai")) {
            m_isListening = false;
            emit isListeningChanged();
            emit notUnderstood();
        }
        return;
    }
    // Instead of intent_failure which is handled by fallback skills, use complete_intent_failure where all skills failed to parse intent
    if (type == QLatin1String("complete_intent_failure")) {
        m_isListening = false;
        emit isListeningChanged();
        emit notUnderstood();
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
    if (type == QLatin1String("recognizer_loop:wakeword")) {
        m_isListening = true;
        emit isListeningChanged();
        return;
    }
    if (type == QLatin1String("recognizer_loop:record_begin") && !m_isListening) {
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
        qDebug() << "Current intent:" << m_currentIntent;
        emit currentIntentChanged();
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
    } else if (type == QLatin1String("mycroft.skills.all_loaded.response")) {
        if (doc[QStringLiteral("data")][QStringLiteral("status")].toBool() == true) {
            m_serverReady = true;
            emit serverReadyChanged();
        }
    } else if (type == QLatin1String("mycroft.ready")) {
        m_serverReady = true;
        emit serverReadyChanged();
    }
    
    if (type == QLatin1String("screen.close.idle.event")) {
        QString skill_idle_event_id = doc[QStringLiteral("data")][QStringLiteral("skill_idle_event_id")].toString();
        emit skillTimeoutReceived(skill_idle_event_id);
    }

    // Check if it's an utterance recognized as an intent
    if (type.contains(QLatin1Char(':')) && !doc[QStringLiteral("data")][QStringLiteral("utterance")].toString().isEmpty()) {
        const QString skill = type.split(QLatin1Char(':')).first();
        if (skill.contains(QLatin1Char('.'))) {
            m_currentSkill = skill;
            qDebug() << "Current skill:" << m_currentSkill;
            emit utteranceManagedBySkill(m_currentSkill);
            emit currentSkillChanged();
        }
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

void MycroftController::sendBinary(const QString &type, const QJsonObject &data) 
{
    if (m_mainWebSocket.state() != QAbstractSocket::ConnectedState) {
        qWarning() << "mycroft connection not open!";
        return;
    }
    QJsonObject socketObject;
    socketObject[QStringLiteral("type")] = type;
    socketObject[QStringLiteral("data")] = data;

    QJsonDocument doc;
    doc.setObject(socketObject);
    QByteArray docbin = doc.toJson(QJsonDocument::Compact);
    m_mainWebSocket.sendBinaryMessage(docbin);
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

QString MycroftController::currentIntent() const
{
    return m_currentIntent;
}

bool MycroftController::isSpeaking() const
{
    return m_isSpeaking;
}

bool MycroftController::isListening() const
{
    return m_isListening;
}

bool MycroftController::serverReady() const
{
    return m_serverReady;
}

#include "moc_mycroftcontroller.cpp"
