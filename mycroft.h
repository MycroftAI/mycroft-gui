#pragma once

#include <QObject>
#include <QWebSocket>

class Mycroft : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status NOTIFY socketStatusChanged)
    Q_PROPERTY(bool speaking READ isSpeaking NOTIFY isSpeakingChanged)
    Q_PROPERTY(QVariantMap currentSkillData READ currentSkillData NOTIFY currentSkillDataChanged)

    Q_ENUMS(Status)
public:
    enum Status {
        Connecting,
        Open,
        Closing,
        Closed,
        Error
    };
    explicit Mycroft(QObject *parent = nullptr);
    bool isSpeaking() const;
    QVariantMap currentSkillData() const;
    Status status() const;

signals:
    void socketStatusChanged();
    void closed();
    void isSpeakingChanged();
    void currentSkillDataChanged();

public slots:
    void open(const QUrl &url);
    void sendRequest(const QString &json);
    void sendText(const QString &message);
private slots:
    void onConnected();
    void onTextMessageReceived(const QString &message);
    void onStatusChanged(QAbstractSocket::SocketState state);
private:
    QWebSocket m_webSocket;
    QUrl m_url;

    bool m_isSpeaking;
    QVariantMap m_currentSkillData;
};

