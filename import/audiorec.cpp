#include "audiorec.h"
#include "controllerconfig.h"

#include <QUrl>
#include <QFile>
#include <QDir>
#include <QDebug>

AudioRec::AudioRec(QObject *parent) :
    QObject(parent),
    m_controller(MycroftController::instance())
{

}

void AudioRec::recordTStart()
{
    destinationFile.setFileName(QStringLiteral("/tmp/mycroft_in.raw"));
    destinationFile.open( QIODevice::WriteOnly | QIODevice::Truncate );

#ifdef BUILD_REMOTE_TTS    
    QAudioFormat format;
    format.setSampleRate(8000);
    format.setChannelCount(1);
    format.setSampleSize(8);
    format.setCodec(QStringLiteral("audio/pcm"));
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::UnSignedInt);

    QAudioDeviceInfo info = QAudioDeviceInfo::defaultInputDevice();
      if (!info.isFormatSupported(format)) {
         qWarning() << "Format is not supported.";
         format = info.nearestFormat(format);
     }

    audio = new QAudioInput(format, this);
    audio->start(&destinationFile);
#endif
}

void AudioRec::recordTStop()
{
#ifdef BUILD_REMOTE_TTS
    audio->stop();
#endif
    destinationFile.close();
    emit recordTStatus(QStringLiteral("Completed"));
}

void AudioRec::readStream()
{
    QFile inputFile;
    QDir::setCurrent(QStringLiteral("/tmp"));
    inputFile.setFileName(QStringLiteral("mycroft_in.raw"));
    m_audStream_size = inputFile.size();
    qDebug() << "filesize: " << m_audStream_size;
    inputFile.open(QIODevice::ReadWrite);
    while(!inputFile.atEnd()) {
      m_audStream = inputFile.readAll();
    }
    inputFile.close();
}

void AudioRec::returnStream()
{
    QJsonObject dataObject;
    QByteArray utteranceArray;
    utteranceArray.push_front(m_audStream.toHex());
    dataObject.insert(QStringLiteral("lang"), QStringLiteral("en-us"));
    dataObject.insert(QStringLiteral("audio"), QJsonValue::fromVariant(utteranceArray));
    m_controller->sendBinary(QStringLiteral("recognizer_loop:incoming_aud"), dataObject);
}
