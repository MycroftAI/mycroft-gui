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
#include "delegate.h"

#include <QWebSocket>
#include <QUuid>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlPropertyMap>


AbstractSkillView::AbstractSkillView(QQuickItem *parent)
    : QQuickItem(parent),
      m_controller(MycroftController::instance()),
      m_id(QUuid::createUuid().toString())
{
    qmlRegisterType<ActiveSkillsModel>();
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


QQmlPropertyMap *AbstractSkillView::sessionDataForSkill(const QString &skillId)
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
        auto doc = QJsonDocument::fromJson(message.toLatin1());

    auto type = doc["type"].toString();
qWarning()<<message;
    //filter out the noise so we can print debug stuff later without drowning in noise
    if (type.startsWith("enclosure") || type.startsWith("mycroft-date")) {
        return;
    }
    qDebug() << "gui message type" << type;

///////////////SKILLDATA
    // The SkillData was updated by the server
    if (type == "mycroft.session.set") {
        QVariantMap data = doc["data"].toVariant().toMap();
//FIXME: remove "data"
        QQmlPropertyMap *map = sessionDataForSkill(doc["namespace"].toString());

        QVariantMap::const_iterator i;
        for (i = data.constBegin(); i != data.constEnd(); ++i) {
            map->insert(i.key(), i.value());
        }

    // The SkillData was updated by the server
    } else if (type == "mycroft.session.delete") {
//FIXME: remove "data"
        const QString skillId = doc["namespace"].toString();
        const QString property = doc["property"].toString();
        if (skillId.isEmpty()) {
            qWarning() << "No skill id provided";
            return;
        }
        if (property.isEmpty()) {
            qWarning() << "No property provided";
            return;
        }
        QQmlPropertyMap *map = sessionDataForSkill(skillId);
        map->clear(property);


//////SHOWGUI
    // The Skill from the server asked to show its gui
    } else if (type == "mycroft.gui.show") {
        //FIXME: KILL "data"
        const QString skillId = doc["namespace"].toString();
        const QUrl guiUrl = doc["gui_url"].toString();

        if (skillId.isEmpty()) {
            qWarning() << "Invalid mycroft.gui.show arrived with empty namespace";
            return;
        }
        if (guiUrl.isEmpty()) {
            qWarning() << "Invalid mycroft.gui.show arrived with empty gui_url";
            return;
        }

        Delegate *delegate = nullptr;
        QQuickItem *guiItem = nullptr;

        auto it = std::find_if(m_guis.constBegin(), m_guis.constEnd(), [&guiUrl](const QHash<QUrl, QQuickItem*> &h) noexcept {
            return h.contains(guiUrl);
        });
        if (it != m_guis.constEnd()) {
            guiItem = it.value().value(guiUrl);
        //initialize a new delegate
        } else {
            QQmlComponent guiComponent(qmlEngine(this), guiUrl, this);
            //TODO: async components for http urls
            delegate = new Delegate(this);
            QQmlEngine::setContextForObject(delegate, QQmlEngine::contextForObject(this));
            QQmlContext *context = new QQmlContext(QQmlEngine::contextForObject(this), delegate);
            context->setContextObject(delegate);
            QObject * guiObject = guiComponent.beginCreate(context);
            guiItem = qobject_cast<QQuickItem *>(guiObject);
            if (guiComponent.isError()) {
                for (auto err : guiComponent.errors()) {
                    qWarning() << err.toString();
                }
                return;
            }
            if (!guiItem) {
                qWarning()<<"ERROR: QML gui not a Mycroft.Delegate instance";
                guiObject->deleteLater();
                delegate->deleteLater();
                return;
            }


            delegate->setSessionData(sessionDataForSkill(skillId));
            guiComponent.completeCreate();
            qWarning()<<"AAAAAAA"<<skillId<<delegate;
            m_guis[skillId].insert(guiUrl, guiItem);
        }

        //TODO: change it to invoking a method on the gui object, to hide it from other skills
//        emit skillGuiCreated(skillId, guiItem);


/////////////ACTIVESKILLS

    // Insert new active skill
    //TODO: remove data
    } else if (type == "mycroft.session.insert" && doc["namespace"].toString() == "mycroft.system.active_skills") {
        const int position = doc["position"].toInt();

        if (position < 0 || position > m_activeSkillsModel->rowCount()) {
            qWarning() << "Invalid position in mycroft.session.insert";
            return;
        }

        const QStringList skillList = jsonModelToStringList(QStringLiteral("skill_id"), doc["data"]);

        if (skillList.isEmpty()) {
            qWarning() << "Error: no valid skills received in mycroft.session.insert";
            return;
        }

        m_activeSkillsModel->insertSkills(position, skillList);


    // Active skill removed
    } else if (type == "mycroft.session.remove" && doc["namespace"].toString() == "mycroft.system.active_skills") {
        const int position = doc["position"].toInt();
        const int itemsNumber = doc["items_number"].toInt();

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
            {
                auto i = m_guis.find(skillId);
                if (i != m_guis.end()) {
                    for (auto d : i.value().values()) {
                        d->deleteLater();
                    }
                    m_guis.erase(i);
                }
            }
        }
        m_activeSkillsModel->removeRows(position, itemsNumber);

    // Active skill moved
    } else if (type == "mycroft.session.move") {
        const int from = doc["from"].toInt();
        const int to = doc["to"].toInt();
        const int itemsNumber = doc["items_number"].toInt();

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
    } else if (type == "mycroft.events.triggered") {
        //TODO: make it visible only from the current skill QML? maybe as a signel of the QQMLpropertyMap?
//        emit eventTriggered(doc["event_id"].toString(), doc["parameters"].toVariant().toMap());
    }
}

#include "moc_abstractskillview.cpp"
