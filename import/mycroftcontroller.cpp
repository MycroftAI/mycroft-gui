/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "mycroftcontroller.h"
#include "globalsettings.h"
#include "delegate.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>
#include <QProcess>
#include <QQmlPropertyMap>
#include <QStandardItemModel>
#include <QQmlEngine>
#include <QQmlContext>

MycroftController *MycroftController::instance()
{
    static MycroftController* s_self = nullptr;
    if (!s_self) {
        s_self = new MycroftController;
    }
    return s_self;
}


MycroftController::MycroftController(QObject *parent)
    : QObject(parent),
      m_appSettingObj(new GlobalSettings)
{
    m_activeSkillsModel = new QStandardItemModel(this);

    connect(&m_webSocket, &QWebSocket::connected, this, &MycroftController::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected, this, &MycroftController::closed);
    connect(&m_webSocket, &QWebSocket::stateChanged, this, &MycroftController::onStatusChanged);
    connect(&m_webSocket, &QWebSocket::textMessageReceived, this, &MycroftController::onTextMessageReceived);

    m_reconnectTimer.setInterval(1000);
    connect(&m_reconnectTimer, &QTimer::timeout, this, [this]() {
        QString socket = m_appSettingObj->webSocketAddress();
        m_webSocket.open(QUrl(socket));
    });

#ifdef Q_OS_ANDROID
    m_speech = new QTextToSpeech(this);
#endif
}


void MycroftController::start()
{
    auto appSettingObj = new GlobalSettings;
    QString socket = m_appSettingObj->webSocketAddress();
    m_webSocket.open(QUrl(socket));
    connect(&m_webSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error),
            this, [this] {
        QProcess::startDetached("mycroft-gui-core-loader");
        m_reconnectTimer.start();
        emit socketStatusChanged();
    });

    emit socketStatusChanged();
}

void MycroftController::reconnect()
{
    qDebug() << "in reconnect";
    m_webSocket.close();
    m_reconnectTimer.start();
    emit socketStatusChanged();
}

void MycroftController::onConnected()
{
    m_reconnectTimer.stop();
    emit socketStatusChanged();
}

QQmlPropertyMap *MycroftController::sessionDataForSkill(const QString &skillId)
{
    QQmlPropertyMap *map;

    if (m_skillData.contains(skillId)) {
        map = m_skillData[skillId];
    } else {
        map = new QQmlPropertyMap(this);
        m_skillData[skillId] = map;
    }

    return map;
}

void MycroftController::onTextMessageReceived(const QString &message)
{
    auto doc = QJsonDocument::fromJson(message.toLatin1());

    auto type = doc["type"].toString();

    //filter out the noise so we can print debug stuff later without drowning in noise
    if (type.startsWith("enclosure") || type.startsWith("mycroft-date")) {
        return;
    }
    qDebug() << "type" << type;

    emit intentRecevied(type, doc["data"].toVariant().toMap());

#ifdef Q_OS_ANDROID
    if (type == "speak") {
        m_speech->say(doc["data"]["utterance"].toString());
    }
#endif

    if (type == QLatin1String("intent_failure")) {
        m_isListening = false;
        emit isListeningChanged();
        emit notUnderstood();
        return;
    }
    if (type == QLatin1String("recognizer_loop:audio_output_start")) {
        m_isSpeaking = true;
        emit isSpeakingChanged();
        return;
    }
    if (type == QLatin1String("recognizer_loop:audio_output_end")) {
        m_isSpeaking = false;
        emit isSpeakingChanged();
        return;
    }
    if (type == QLatin1String("recognizer_loop:record_begin")) {
        m_isListening = true;
        emit isListeningChanged();
        return;
    }
    if (type == QLatin1String("recognizer_loop:record_end")) {
        m_isListening = false;
        emit isListeningChanged();
        return;
    }
    if (type == QLatin1String("mycroft.speech.recognition.unknown")) {
        emit notUnderstood();
        return;
    }

    if (type == "mycroft.skill.handler.start") {
        m_currentSkill = doc["data"]["name"].toString();
        qDebug() << "Current skill:" << m_currentSkill;
        emit currentSkillChanged();
    } else if (type == "mycroft.skill.handler.complete") {
        m_currentSkill = QString();
        emit currentSkillChanged();
    } else if (type == "speak") {
        emit fallbackTextRecieved(m_currentSkill, doc["data"].toVariant().toMap());
    } else if (type == QLatin1String("mycroft.stop.handled") || type == QLatin1String("mycroft.stop")) {
        emit stopped();
    //TODO: remove
    } else if (type == "metadata") {
        emit skillDataRecieved(doc["data"].toVariant().toMap());


///////////////SKILLDATA
    // The SkillData was updated by the server
    } else if (type == "mycroft.session.set") {
        QVariantMap data = doc["data"].toVariant().toMap();
//FIXME: remove "data"
        QQmlPropertyMap *map = sessionDataForSkill(doc["data"]["namespace"].toString());

        QVariantMap::const_iterator i;
        for (i = data.constBegin(); i != data.constEnd(); ++i) {
            map->insert(i.key(), i.value());
        }

//////SHOWGUI
    // The Skill from the server asked to show its gui
    } else if (type == "mycroft.gui.show") {
        //FOXME: KILL "data"
        const QString skillId = doc["data"]["namespace"].toString();
        const QUrl guiUrl = doc["data"]["gui_url"].toString();

        if (skillId.isEmpty()) {
            qWarning() << "Invalid mycroft.gui.show arrived with empty namespace";
            return;
        }
        if (guiUrl.isEmpty()) {
            qWarning() << "Invalid mycroft.gui.show arrived with empty gui_url";
            return;
        }

        Delegate *delegate = nullptr;

        auto it = std::find_if(m_guis.constBegin(), m_guis.constEnd(), [&guiUrl](const QHash<QUrl, Delegate*> &h) noexcept {
            return h.contains(guiUrl);
        });
        if (it != m_guis.constEnd()) {
            delegate = it.value().value(guiUrl);
        //initialize a new delegate
        } else {
            QQmlComponent guiComponent(qmlEngine(m_gui), guiUrl, this);
            //TODO: async components for http urls
            QObject * guiObject = guiComponent.beginCreate(QQmlEngine::contextForObject(m_gui));
            delegate = qobject_cast<Delegate *>(guiObject);
            if (guiComponent.isError()) {
                for (auto err : guiComponent.errors()) {
                    qWarning() << err.toString();
                }
                return;
            }
            if (!delegate) {
                qWarning()<<"ERROR: QML gui not a Mycroft.Delegate instance";
                guiObject->deleteLater();
                return;
            }
            delegate->setSessionData(sessionDataForSkill(skillId));
            guiComponent.completeCreate();
        }

        m_guis[skillId].insert(guiUrl, delegate);
        emit skillGuiCreated(delegate);


/////////////ACTIVESKILLS
    // New full list of active skills
    } else if (type == "mycroft.active_skills.list") {
        m_activeSkillsModel->clear();
        QVariantList list = doc["list"].toVariant().toList();

        QList<QStandardItem *> items;
        for (const auto &item : list) {
            items << new QStandardItem(item.toString());
        }
        m_activeSkillsModel->appendRow(items);

    // New active skill
    } else if (type == "mycroft.active_skills.new") {
        //TODO: always append?
        bool found = false;
        for (int i = 0; i < m_activeSkillsModel->rowCount(); ++i) {
            if (m_activeSkillsModel->data(m_activeSkillsModel->index(i, 0)).toString() == doc["namespace"].toString()) {
                found = true;
            }
        }

        if (!found) {
            m_activeSkillsModel->appendRow(new QStandardItem(doc["namespace"].toString()));
        }

    // Active skill removed
    } else if (type == "mycroft.active_skills.remove") {
        const QString skillId = doc["namespace"].toString();
        //FIXME: OR: instead of the skill string, directly the row number
        for (int i = 0; i < m_activeSkillsModel->rowCount(); ++i) {
            if (m_activeSkillsModel->data(m_activeSkillsModel->index(i, 0)).toString() == skillId) {
                m_activeSkillsModel->removeRow(i);
                break;
            }
        }

        //TODO: do this after an animation
        {
            auto i = m_skillData.find(skillId);
            if (i != m_skillData.end()) {
                i.value()->deleteLater();
                m_skillData.erase(i);
            }
        }
        {
            auto i = m_guis.find(skillId);
            if (i != m_guis.end()) {
                for (auto d : i.value().values()) {
                    d->deleteLater();
                }
                m_guis.erase(i);
            }
        }

    // Active skill moved
    } else if (type == "mycroft.active_skills.moved") {
        m_activeSkillsModel->moveRows(QModelIndex(), doc["from"].toInt(), 1, QModelIndex(), doc["to"].toInt());



//////ACTIONS
    // Action triggered from the server
    } else if (type == "mycroft.events.triggered") {
        //TODO: make it visible only from the current skill QML? maybe as a signel of the QQMLpropertyMap?
        emit eventTriggered(doc["event_id"].toString(), doc["parameters"].toVariant().toMap());
    }
}

void MycroftController::sendRequest(const QString &type, const QVariantMap &data)
{
    if (m_webSocket.state() != QAbstractSocket::ConnectedState) {
        qWarning() << "mycroft connection not open!";
        return;
    }
    QJsonObject root;

    root["type"] = type;
    root["data"] = QJsonObject::fromVariantMap(data);

    QJsonDocument doc(root);
    m_webSocket.sendTextMessage(doc.toJson());
}

void MycroftController::sendText(const QString &message)
{
    sendRequest(QStringLiteral("recognizer_loop:utterance"), QVariantMap({{"utterances", QStringList({message})}}));
}

void MycroftController::registerGui(QQuickItem *gui)
{
    //TODO: support more than one
    m_gui = gui;
}

void MycroftController::triggerAction(const QString &actionId, const QVariantMap &parameters)
{
    sendRequest(QStringLiteral("mycroft.actions.trigger"),
                QVariantMap({{"actionId", actionId}, {"parameters", parameters}})
    );
}

void MycroftController::onStatusChanged(QAbstractSocket::SocketState state)
{
    emit socketStatusChanged();
    //qDebug() << "State changed to " << status();
}

MycroftController::Status MycroftController::status() const
{
    if (m_reconnectTimer.isActive()) {
        return Connecting;
    }

    switch(m_webSocket.state())
    {
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::BoundState:
    case QAbstractSocket::HostLookupState:
        return Connecting;
    case QAbstractSocket::UnconnectedState:
        return Closed;
    case QAbstractSocket::ConnectedState:
        return Open;
    case QAbstractSocket::ClosingState:
        return Closing;
    default:
        return Connecting;
    }
}

//FIXME: remove
QString MycroftController::currentSkill() const
{
    return m_currentSkill;
}

QStandardItemModel *MycroftController::activeSkills() const
{
    return m_activeSkillsModel;
}

bool MycroftController::isSpeaking() const
{
    return m_isSpeaking;
}

bool MycroftController::isListening() const
{
    return m_isListening;
}

