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

#include "speechintent.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QAndroidActivityResultReceiver>
#endif


#ifdef Q_OS_ANDROID

static int s_receiverRequestCode = 42;

class SpeechIntentResultReceiver : public QAndroidActivityResultReceiver
{
public:
    SpeechIntentResultReceiver(SpeechIntent *q);
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data) override;

private:
    SpeechIntent *q;

};

SpeechIntentResultReceiver::SpeechIntentResultReceiver(SpeechIntent *q)
    : q(q)
{

}

void SpeechIntentResultReceiver::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
{
    if (!q) {
        return;
    }

    if (receiverRequestCode != s_receiverRequestCode) {
        return;
    }

    static int resultOk = QAndroidJniObject::getStaticField<jint>("android/app/Activity", "RESULT_OK");
    static int resultCanceled = QAndroidJniObject::getStaticField<jint>("android/app/Activity", "RESULT_CANCELED");

    if (resultCode == resultCanceled) {
        emit q->recognitionCanceled();
        return;
    }

    if (resultCode != resultOk) {
        emit q->recognitionFailed();
        return;
    }

    if (!data.isValid()) { // can this happen?
        emit q->recognitionFailed();
        return;
    }

    QAndroidJniObject extraResultsKey = QAndroidJniObject::getStaticObjectField<jstring>("android/speech/RecognizerIntent", "EXTRA_RESULTS");
    Q_ASSERT(extraResultsKey.isValid());

    QAndroidJniObject results = data.callObjectMethod("getStringArrayListExtra",
                                                      "(Ljava/lang/String;)Ljava/util/ArrayList;",
                                                      extraResultsKey.object());

    if (data.callMethod<jboolean>("isEmpty")) {
        emit q->nothingRecognized();
        return;
    }

    QAndroidJniObject firstResult = results.callObjectMethod("get", "(I)Ljava/lang/Object;", static_cast<jint>(0));

    const QString text = firstResult.toString();
    if (text.isEmpty()) {
        emit q->nothingRecognized();
        return;
    }

    emit q->speechRecognized(text);
}
#endif // Q_OS_ANDROID

SpeechIntent::SpeechIntent(QObject *parent) : QObject(parent)
{

}

SpeechIntent::~SpeechIntent() = default;

QString SpeechIntent::title() const
{
    return m_title;
}

void SpeechIntent::setTitle(const QString &title)
{
    if (m_title != title) {
        m_title = title;
        emit titleChanged(title);
    }
}

bool SpeechIntent::isSupported() const
{
#ifdef Q_OS_ANDROID
    // TODO check for whether the intent class exists or permission or whatever?
    return true;
#else
    return false;
#endif
}

void SpeechIntent::start()
{
#ifdef Q_OS_ANDROID
    if (!m_receiver) {
        m_receiver.reset(new SpeechIntentResultReceiver(this));
    }

    QAndroidJniObject actionRecognizeSpeech = QAndroidJniObject::getStaticObjectField<jstring>("android/speech/RecognizerIntent", "ACTION_RECOGNIZE_SPEECH");

    QAndroidJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", actionRecognizeSpeech.object());

    QAndroidJniObject extraLanguageModel = QAndroidJniObject::getStaticObjectField<jstring>("android/speech/RecognizerIntent", "EXTRA_LANGUAGE_MODEL");
    QAndroidJniObject langaugeModelFreeForm = QAndroidJniObject::getStaticObjectField<jstring>("android/speech/RecognizerIntent", "LANGUAGE_MODEL_FREE_FORM");

    intent.callObjectMethod("putExtra",
                            "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
                            extraLanguageModel.object(),
                            langaugeModelFreeForm.object());

    if (!m_title.isEmpty()) {
        QAndroidJniObject extraPrompt = QAndroidJniObject::getStaticObjectField<jstring>("android/speech/RecognizerIntent", "EXTRA_PROMPT");

        intent.callObjectMethod("putExtra",
                                "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
                                extraPrompt.object(),
                                QAndroidJniObject::fromString(m_title).object());
    }

    QtAndroid::startActivity(intent, s_receiverRequestCode, m_receiver.data());
#endif // Q_OS_ANDROID
}
