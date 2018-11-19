/*
 * Copyright 2018 Kai Uwe Broulik <kde@broulik.de>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <QObject>
#include <QScopedPointer>

class SpeechIntentResultReceiver;

class SpeechIntent : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(bool supported READ isSupported CONSTANT)

public:
    explicit SpeechIntent(QObject *parent = nullptr);
    ~SpeechIntent() override;

    QString title() const;
    void setTitle(const QString &title);

    bool isSupported() const;

    Q_INVOKABLE void start();

signals:
    void titleChanged(const QString &title);

    void speechRecognized(const QString &text);
    void recognitionFailed(); // TODO forward error code or error string
    void recognitionCanceled();
    void nothingRecognized();

private:
#ifdef Q_OS_ANDROID
    QScopedPointer<SpeechIntentResultReceiver> m_receiver;
#endif

    QString m_title;

};
