#include "mycroft.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>

Mycroft::Mycroft(QObject *parent): QObject(parent)
{
    connect(&m_webSocket, &QWebSocket::connected, this, &Mycroft::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected, this, &Mycroft::closed);
    connect(&m_webSocket, &QWebSocket::stateChanged, this, &Mycroft::onStatusChanged);
    connect(&m_webSocket, &QWebSocket::textMessageReceived, this, &Mycroft::onTextMessageReceived);
}

void Mycroft::open(const QUrl &url)
{
    m_webSocket.open(QUrl(url));
}

void Mycroft::onConnected()
{
}

void Mycroft::onTextMessageReceived(const QString &message)
{
    auto doc = QJsonDocument::fromJson(message.toLatin1());

    auto type = doc["type"].toString();
    qDebug() << message;

    //filter out the noise so we can print debug stuff later without drowning in noise
    if (type.startsWith("enclosure") || type.startsWith("mycroft-date")) {
        return;
    }

    if (type == QLatin1String("intent_failure")) {
        m_isListening = false;
        emit isListeningChanged();
        emit notUnderstood();qWarning()<<"HHHHHH";
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

    if (type == "mycroft.skill.handler.start") {
        m_currentSkill = doc["data"]["name"].toString();
        emit currentSkillChanged();
    }
    if (type == "mycroft.skill.handler.complete") {
        m_currentSkill = QString();
        emit currentSkillChanged();
    }
    if (type == "speak") {
        emit skillDataRecieved(m_currentSkill, doc["data"].toVariant().toMap());
    }
    if (type == QLatin1String("metadata")) {
        emit skillDataRecieved(m_currentSkill, doc["data"].toVariant().toMap());
    }
}

void Mycroft::sendRequest(const QString &json)
{
    if (m_webSocket.state() != QAbstractSocket::ConnectedState) {
        qWarning() << "mycroft connection not open!";
        return;
    }
    m_webSocket.sendTextMessage(json);
}

void Mycroft::sendText(const QString &message)
{
    QJsonObject root;
    root["type"] = "recognizer_loop:utterance";
    root["data"] = QJsonObject({{"utterances", QJsonArray({message})}});

    QJsonDocument doc(root);
    sendRequest(doc.toJson());
}


void Mycroft::onStatusChanged(QAbstractSocket::SocketState state)
{
    emit socketStatusChanged();
    qDebug() << "State changed to " << status();
}

Mycroft::Status Mycroft::status() const
{
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

QString Mycroft::currentSkill() const
{
    return m_currentSkill;
}
bool Mycroft::isSpeaking() const
{
    return m_isSpeaking;
}
bool Mycroft::isListening() const
{
    return m_isListening;
}
