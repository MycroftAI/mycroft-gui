#include "wsocket.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>

WSocket::WSocket(QObject *parent) : QObject(parent)
{
    connect(&m_webSocket, &QWebSocket::connected, this, &WSocket::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected, this, &WSocket::closed);
    connect(&m_webSocket, &QWebSocket::stateChanged, this, &WSocket::onStatusChanged);
}

void WSocket::open(const QUrl &url){
    qDebug() << "Websocket-Open";
    m_webSocket.open(QUrl(url));
}

void WSocket::onConnected()
{
    connect(&m_webSocket, &QWebSocket::textMessageReceived, this, &WSocket::onTextMessageReceived);
}

void WSocket::onTextMessageReceived(QString message)
{
    emit messageReceived(message);
}

void WSocket::onSendMessage(QString message)
{
    m_webSocket.sendTextMessage(message);
}

void WSocket::onStatusChanged(QAbstractSocket::SocketState state)
{
        qDebug() << "Debug:Emit";
    //emit socketStatusChanged(status());
}

WSocket::Status WSocket::status(){
    switch(m_webSocket.state())
    {
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::BoundState:
    case QAbstractSocket::HostLookupState:
    {
    qDebug() << "Debug:Connecting";
        return Connecting;
    break;
    }
    case QAbstractSocket::UnconnectedState:
    {
    qDebug() << "Debug:Closed";
    return Closed;
    break;
    }
    case QAbstractSocket::ConnectedState:
    {
    qDebug() << "Debug:Open";
    return Open;
    break;
    }
    case QAbstractSocket::ClosingState:
    {
            qDebug() << "Debug:Closing";
    return Closing;
    break;
    }
    default:
    {
        qDebug() << "Debug:ConnectingDefault";
    return Connecting;
    break;
    }
    }
}
