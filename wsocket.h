#ifndef WSOCKETS_H
#define WSOCKETS_H

#include <QObject>
#include <QWebSocket>

class WSocket : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status NOTIFY socketStatusChanged)
    Q_ENUMS(Status)
public:
    enum Status {
        Connecting,
        Open,
        Closing,
        Closed,
        Error
    };
    explicit WSocket(QObject *parent = nullptr);
signals:
    void messageReceived(QString message);
    void socketStatusChanged();
    void closed();
public slots:
    void onConnected();
    void open(const QUrl &url);
    void onTextMessageReceived(QString message);
    void onSendMessage(QString message);
    void onStatusChanged(QAbstractSocket::SocketState state);
    Status status();
private:
    QWebSocket m_webSocket;
    QUrl m_url;
};

#endif // WSOCKETS_H
