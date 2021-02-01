#ifndef AUDIOREC_H
#define AUDIOREC_H

#include <QObject>
#include <QFile>
#include <QtWebSockets>
#include "mycroftcontroller.h"
#include "controllerconfig.h"

#include <QAudioInput>

class AudioRec : public QObject
{
    Q_OBJECT
public:
    explicit AudioRec(QObject *parent = nullptr);

public Q_SLOTS:
    void recordTStart();
    void recordTStop();
    void readStream();
    void returnStream();
    void captureDataFromDevice();

Q_SIGNALS:
    void recordTStatus(const QString &recStatus);
    void micAudioLevelChanged(const qreal &micLevel);

private:
    MycroftController *m_controller;
    QFile destinationFile;
    QByteArray m_audStream;
    qint16 m_audStream_size;
    QAudioInput *audio;
    QIODevice *device;
};

#endif // AUDIOREC_H
 
