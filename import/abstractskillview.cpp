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

#include "abstractskillview.h"
#include "activeskillsmodel.h"
#include "abstractdelegate.h"
#include "sessiondatamap.h"

#include <QWebSocket>
#include <QUuid>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QQmlContext>
#include <QQmlEngine>


AbstractSkillView::AbstractSkillView(QQuickItem *parent)
    : QQuickItem(parent),
      m_controller(MycroftController::instance()),
      m_id(QUuid::createUuid().toString())
{
    m_activeSkillsModel = new ActiveSkillsModel(this);

    m_guiWebSocket = new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this);
    m_controller->registerView(this);

    connect(m_guiWebSocket, &QWebSocket::connected, this,
            [this] () {
                m_reconnectTimer.stop();
                emit statusChanged();
            });

    connect(m_guiWebSocket, &QWebSocket::disconnected, this, &AbstractSkillView::closed);

    connect(m_guiWebSocket, &QWebSocket::stateChanged, this,
            [this] (QAbstractSocket::SocketState state) {
                emit statusChanged();
            });

    connect(m_guiWebSocket, &QWebSocket::textMessageReceived, this, &AbstractSkillView::onGuiSocketMessageReceived);

    connect(m_guiWebSocket, &QWebSocket::stateChanged, this,
            [this](QAbstractSocket::SocketState socketState) {
                //TODO: when the connection closes, all session data and guis should be destroyed
                qWarning()<<"GUI SOCKET STATE:"<<socketState;
                //Try to reconnect if our connection died but the main server connection is still alive
                if (socketState == QAbstractSocket::UnconnectedState && m_url.isValid() && m_controller->status() == MycroftController::Open) {
                    m_reconnectTimer.start();
                }
            });



    connect(m_controller, &MycroftController::socketStatusChanged, this,
            [this]() {
                if (m_controller->status() == MycroftController::Open) {
                    if (m_url.isValid()) {
                        m_guiWebSocket->close();
                        m_guiWebSocket->open(m_url);
                    }
                } else if (status() != MycroftController::Open) {
                    m_guiWebSocket->close();
                    //don't assume the url will be still valid
                    m_url = QUrl();
                }
            });

    //Reconnect timer
    m_reconnectTimer.setInterval(1000);
    connect(&m_reconnectTimer, &QTimer::timeout, this, [this]() {
        m_guiWebSocket->close();
        m_guiWebSocket->open(m_url);
    });
}

AbstractSkillView::~AbstractSkillView()
{
}


QUrl AbstractSkillView::url() const
{
    return m_url;
}

void AbstractSkillView::setUrl(const QUrl &url)
{
    if (m_url == url) {
        return;
    }

    m_url = url;

    //don't connect if the controller is offline
    if (m_controller->status() == MycroftController::Open) {
        m_guiWebSocket->close();
        m_guiWebSocket->open(url);
    }
}

QString AbstractSkillView::id() const
{
    return m_id;
}

MycroftController::Status AbstractSkillView::status() const
{
    if (m_reconnectTimer.isActive()) {
        return MycroftController::Connecting;
    }

    switch(m_guiWebSocket->state())
    {
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::BoundState:
    case QAbstractSocket::HostLookupState:
        return MycroftController::Connecting;
    case QAbstractSocket::UnconnectedState:
        return MycroftController::Closed;
    case QAbstractSocket::ConnectedState:
        return MycroftController::Open;
    case QAbstractSocket::ClosingState:
        return MycroftController::Closing;
    default:
        return MycroftController::Connecting;
    }
}

ActiveSkillsModel *AbstractSkillView::activeSkills() const
{
    return m_activeSkillsModel;
}


SessionDataMap *AbstractSkillView::sessionDataForSkill(const QString &skillId)
{
    SessionDataMap *map = nullptr;

    if (m_skillData.contains(skillId)) {
        map = m_skillData[skillId];
    } else if (m_activeSkillsModel->skillIndex(skillId).isValid()) {
        map = new SessionDataMap(this);
        m_skillData[skillId] = map;
    }

    return map;
}

QList<QVariantMap> jsonModelToOrderedMap(const QJsonValue &data)
{
    QList<QVariantMap> ordMap;

    if (!data.isArray()) {
        qWarning() << "Error: Model data is not an Array" << data;
        return ordMap;
    }

    QStringList roleNames;

    const auto &array = data.toArray();
    for (const auto &item : array) {
        if (!item.isObject()) {
            qWarning() << "Error: Array data structure currupted: " << data;
            ordMap.clear();
            return ordMap;
        }
        const auto &obj = item.toObject();
        if (roleNames.isEmpty()) {
            roleNames = obj.keys();
        } else if (roleNames != obj.keys()) {
            qWarning() << "Error: Item with a wrong set of roles encountered, expected: " << roleNames << "Encountered: " << obj.keys();
            ordMap.clear();
            return ordMap;
        }
        ordMap << obj.toVariantMap();
    }

    return ordMap;
}

QStringList jsonModelToStringList(const QString &key, const QJsonValue &data)
{
    QStringList items;

    if (!data.isArray()) {
        qWarning() << "Error: Model data is not an Array" << data;
        return items;
    }

    const auto &array = data.toArray();
    for (const auto &item : array) {
        if (!item.isObject()) {
            qWarning() << "Error: Array data structure currupted: " << data;
            items.clear();
            return items;
        }
        const auto &obj = item.toObject();
        if (obj.keys().length() != 1 || !obj.contains(key)) {
            qWarning() << "Error: Item with a wrong key encountered, expected: " << key << "Encountered: " << obj.keys();
            items.clear();
            return items;
        }
        const auto &value = obj.value(key);
        if (!value.isString()) {
            qWarning() << "Error: item in model not a string" << value;
        }
        items << value.toString();
    }

    return items;
}

void AbstractSkillView::onGuiSocketMessageReceived(const QString &message)
{
    auto doc = QJsonDocument::fromJson(message.toUtf8());

    if (doc.isEmpty()) {
        qWarning() << "Empty or invalid JSON message arrived on the gui socket:" << message;
        return;
    }

    auto type = doc[QStringLiteral("type")].toString();

    if (type.isEmpty()) {
        qWarning() << "Empty type in the JSON message on the gui socket";
        return;
    }

    //filter out the noise so we can print debug stuff later without drowning in noise
    if (type.startsWith(QStringLiteral("enclosure")) || type.startsWith(QStringLiteral("mycroft-date"))) {
        return;
    }
    qDebug() << "gui message type" << type;

///////////////SKILLDATA
    // The SkillData was updated by the server
    if (type == QLatin1String("mycroft.session.set")) {
        const QString skillId = doc[QStringLiteral("namespace")].toString();
        const QVariantMap data = doc[QStringLiteral("data")].toVariant().toMap();

        if (skillId.isEmpty()) {
            qWarning() << "Empty skill_id in mycroft.session.set";
            return;
        }
        if (!m_activeSkillsModel->skillIndex(skillId).isValid()) {
            qWarning() << "Invalid skill_id in mycroft.session.set:" << skillId;
            return;
        }
        if (data.isEmpty()) {
            qWarning() << "Empty dtata in mycroft.session.set";
            return;
        }

        //we already checked, assume *map is valid
        SessionDataMap *map = sessionDataForSkill(skillId);
         QVariantMap::const_iterator i;
        for (i = data.constBegin(); i != data.constEnd(); ++i) {
            map->insertAndNotify(i.key(), i.value());
        }

    // The SkillData was removed by the server
    } else if (type == QLatin1String("mycroft.session.delete")) {
        const QString skillId = doc[QStringLiteral("namespace")].toString();
        const QString property = doc[QStringLiteral("property")].toString();
        if (skillId.isEmpty()) {
            qWarning() << "No skill_id provided in mycroft.session.delete";
            return;
        }
        if (!m_activeSkillsModel->skillIndex(skillId).isValid()) {
            qWarning() << "Invalid skill_id in mycroft.session.set:" << skillId;
            return;
        }
        if (property.isEmpty()) {
            qWarning() << "No property provided in mycroft.session.delete";
            return;
        }
        SessionDataMap *map = sessionDataForSkill(skillId);
        map->clearAndNotify(property);


//////SHOWGUI
    // The Skill from the server asked to show its gui
    } else if (type == QLatin1String("mycroft.gui.show")) {
        const QString skillId = doc[QStringLiteral("namespace")].toString();
        const QUrl delegateUrl(doc[QStringLiteral("gui_url")].toString());

        if (skillId.isEmpty()) {
            qWarning() << "Invalid mycroft.gui.show arrived with empty namespace";
            return;
        }
        if (delegateUrl.isEmpty()) {
            qWarning() << "Invalid mycroft.gui.show arrived with empty gui_url";
            return;
        }

        AbstractDelegate *delegate = m_activeSkillsModel->delegateForSkill(skillId, delegateUrl);

        if (delegate) {
            emit delegate->currentRequested();
        } else {
            QQmlEngine *engine = qmlEngine(this);
            QQmlContext *context = QQmlEngine::contextForObject(this);
            //NOTE: this should happen only when running as autotest
            //TODO: an ifdef?
            if (!engine) {
                engine = new QQmlEngine(this);
                context = engine->rootContext();
            }
            QQmlComponent delegateComponent(engine, delegateUrl, this);
            //TODO: separate context?
            QObject *guiObject = delegateComponent.beginCreate(context);
            delegate = qobject_cast<AbstractDelegate *>(guiObject);
            if (delegateComponent.isError()) {
                for (auto err : delegateComponent.errors()) {
                    qWarning() << err.toString();
                }
                return;
            }
            if (!delegate) {
                qWarning()<<"ERROR: QML gui not a Mycroft.AbstractDelegate instance";
                delegate->deleteLater();
                return;
            }

            delegate->setQmlUrl(delegateUrl);
            delegate->setSessionData(sessionDataForSkill(skillId));
            delegateComponent.completeCreate();
            m_activeSkillsModel->insertDelegateForSkill(skillId, delegate);
            emit delegate->currentRequested();
        }

        //TODO: change it to invoking a method on the gui object, to hide it from other skills
//        emit skillGuiCreated(skillId, guiItem);


/////////////ACTIVESKILLS

    // Insert new active skill
    //TODO: remove data
    } else if (type == QLatin1String("mycroft.session.insert") && doc[QStringLiteral("namespace")].toString() == QLatin1String("mycroft.system.active_skills")) {
        const int position = doc[QStringLiteral("position")].toInt();

        if (position < 0 || position > m_activeSkillsModel->rowCount()) {
            qWarning() << "Invalid position in mycroft.session.insert";
            return;
        }

        const QStringList skillList = jsonModelToStringList(QStringLiteral("skill_id"), doc[QStringLiteral("data")]);

        if (skillList.isEmpty()) {
            qWarning() << "Error: no valid skills received in mycroft.session.insert";
            return;
        }

        m_activeSkillsModel->insertSkills(position, skillList);


    // Active skill removed
    } else if (type == QLatin1String("mycroft.session.remove") && doc[QStringLiteral("namespace")].toString() == QLatin1String("mycroft.system.active_skills")) {
        const int position = doc[QStringLiteral("position")].toInt();
        const int itemsNumber = doc[QStringLiteral("items_number")].toInt();

        if (position < 0 || position > m_activeSkillsModel->rowCount() - 1) {
            qWarning() << "Invalid position";
            return;
        }
        if (itemsNumber < 0 || itemsNumber > m_activeSkillsModel->rowCount() - position - 1) {
            qWarning() << "Invalid items_number";
            return;
        }

        for (int i = 0; i < itemsNumber; ++i) {

            const QString skillId = m_activeSkillsModel->data(m_activeSkillsModel->index(position+i, 0)).toString();

            //TODO: do this after an animation
            {
                auto i = m_skillData.find(skillId);
                if (i != m_skillData.end()) {
                    i.value()->deleteLater();
                    m_skillData.erase(i);
                }
            }
        }
        m_activeSkillsModel->removeRows(position, itemsNumber);

    // Active skill moved
    } else if (type == QLatin1String("mycroft.session.move")) {
        const int from = doc[QStringLiteral("from")].toInt();
        const int to = doc[QStringLiteral("to")].toInt();
        const int itemsNumber = doc[QStringLiteral("items_number")].toInt();

        if (from < 0 || from > m_activeSkillsModel->rowCount() - 1) {
            qWarning() << "Invalid from position";
            return;
        }
        if (to < 0 || to > m_activeSkillsModel->rowCount() - 1) {
            qWarning() << "Invalid to position";
            return;
        }
        if (itemsNumber <= 0 || itemsNumber > m_activeSkillsModel->rowCount() - from) {
            qWarning() << "Invalid items_number";
            return;
        }
        m_activeSkillsModel->moveRows(QModelIndex(), from, itemsNumber, QModelIndex(), to);



//////EVENTS TODO
    // Action triggered from the server
    } else if (type == QLatin1String("mycroft.events.triggered")) {
        //TODO: make it visible only from the current skill QML? maybe as a signel of the QQMLpropertyMap?
//        emit eventTriggered(doc["event_id"].toString(), doc["parameters"].toVariant().toMap());
    }
}

#include "moc_abstractskillview.cpp"
