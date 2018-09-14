#pragma once

#include <QObject>
#include <QWebSocket>
#include <QTimer>

class MycroftController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status NOTIFY socketStatusChanged)
    Q_PROPERTY(bool speaking READ isSpeaking NOTIFY isSpeakingChanged)
    Q_PROPERTY(bool listening READ isListening NOTIFY isListeningChanged)
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
    static MycroftController* instance();

    bool isSpeaking() const;
    bool isListening() const;
    Status status() const;
    QString currentSkill() const;

signals:
    //socket stuff
    void socketStatusChanged();
    void closed();

    //mycroft
    void isSpeakingChanged();
    void isListeningChanged();
    void stopped();
    void notUnderstood();
    void currentSkillChanged();

    //signal with nearly all data
    void intentRecevied(const QString &type, const QVariantMap &data);
    //type == metadata
    void skillDataRecieved(const QVariantMap &data);
    //type utterances, type is the current skill
    void fallbackTextRecieved(const QString &skill, const QVariantMap &data);

public slots:
    void start();
    void sendRequest(const QString &type, const QVariantMap &data);
    void sendText(const QString &message);
private slots:
    void onConnected();
    void onTextMessageReceived(const QString &message);
    void onStatusChanged(QAbstractSocket::SocketState state);
private:
    explicit MycroftController(QObject *parent = nullptr);

    QWebSocket m_webSocket;
    QTimer m_reconnectTimer;

    QString m_currentSkill;
    bool m_isSpeaking = false;
    bool m_isListening = false;
};

