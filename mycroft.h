#pragma once

#include <QObject>
#include <QWebSocket>

class Mycroft : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status NOTIFY socketStatusChanged)
    Q_PROPERTY(bool speaking READ isSpeaking NOTIFY isSpeakingChanged)
    Q_PROPERTY(QString currentSkill READ currentSkill NOTIFY currentSkillChanged)

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
    Status status() const;
    QString currentSkill() const;

signals:
    void socketStatusChanged();
    void closed();
    void isSpeakingChanged();
    void currentSkillChanged();
    void skillDataRecieved(const QString &skill, const QVariantMap &data);

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

    QString m_currentSkill;
    bool m_isSpeaking = false;
};

