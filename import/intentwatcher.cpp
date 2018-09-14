#include "intentwatcher.h"

#include "mycroftcontroller.h"

IntentWatcher::IntentWatcher(QObject *parent)
    :QObject(parent)
{
    connect(MycroftController::instance(), &MycroftController::intentRecevied, this, [this](const QString &type, const QVariantMap &data) {
        if (type == m_type) {
            emit invoked(data);
        }
    });
}

