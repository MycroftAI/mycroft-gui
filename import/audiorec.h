#ifndef AUDIOREC_H
#define AUDIOREC_H

#include <QObject>
#include <QAudioInput>
#include <QFile>
#include <QtWebSockets>
#include "mycroftcontroller.h"

class AudioRec : public QObject
{
    Q_OBJECT
public:
    explicit AudioRec(QObject *parent = nullptr);

    Q_INVOKABLE void recordTStart();
    Q_INVOKABLE void recordTStop();
    Q_INVOKABLE void readStream();
    Q_INVOKABLE void returnStream();

Q_SIGNALS:
    void recordTStatus(const QString &recStatus);

private:
    MycroftController *m_controller;
    QFile destinationFile;
    QAudioInput* audio;
    QByteArray m_audStream;
    qint16 m_audStream_size;
};

#endif // AUDIOREC_H
 
