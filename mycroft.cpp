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
     qDebug() << message;

    auto doc = QJsonDocument::fromJson(message.toLatin1());
    qDebug() << doc["type"].toString();

//     20:18:01.759 Mycroft::onTextMessageReceived "{\"type\": \"speak\", \"data\": {\"utterance\": \"Why did the programmer quit his job? Because they didn't get arrays.\", \"expect_response\": false}, \"context\": {\"target\": null}}"

// 20:18:02.041 Mycroft::onTextMessageReceived "{\"type\": \"recognizer_loop:audio_output_start\", \"data\": {}, \"context\": null}"
//
//     20:18:06.859 Mycroft::onTextMessageReceived "{\"type\": \"recognizer_loop:audio_output_end\", \"data\": {}, \"context\": null}"


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
    root["data"] = QJsonObject({{"utterances", message}});

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

QVariantMap Mycroft::currentSkillData() const
{
    return m_currentSkillData;
}

bool Mycroft::isSpeaking() const
{
    return m_isSpeaking;
}
