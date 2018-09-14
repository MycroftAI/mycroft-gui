#pragma once

#include <QObject>

class IntentWatcher: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString intent MEMBER m_type NOTIFY intentChanged)
public:
    IntentWatcher(QObject *parent = nullptr);
Q_SIGNALS:
    void intentChanged();
    void invoked(const QVariantMap &data);
private:
    QString m_type;
};

