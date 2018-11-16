/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
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

#include <QtTest>
#include <QWebSocket>
#include <QWebSocketServer>
#include <QAbstractItemModel>
#include "../import/mycroftcontroller.h"
#include "../import/abstractdelegate.h"
#include "../import/activeskillsmodel.h"
#include "../import/abstractskillview.h"

class ServerTest : public QObject
{
    Q_OBJECT

public Q_SLOTS:
    void initTestCase();

private Q_SLOTS:
    void testGuiConnection();
    void testActiveSkills();
    void testSessionData();
    void testShowGui();

private:
    //Client
    MycroftController *m_controller;
    AbstractSkillView *m_view;

    //Server
    QWebSocketServer *m_mainServerSocket;
    QWebSocketServer *m_guiServerSocket;

    QWebSocket *m_mainWebSocket;
    QWebSocket *m_guiWebSocket;
};


void ServerTest::initTestCase()
{
    m_mainServerSocket = new QWebSocketServer(QStringLiteral("core"),
                                            QWebSocketServer::NonSecureMode, this);
    m_mainServerSocket->listen(QHostAddress::Any, 8181);
    m_guiServerSocket = new QWebSocketServer(QStringLiteral("gui"),
                                            QWebSocketServer::NonSecureMode, this);
    m_guiServerSocket->listen(QHostAddress::Any, 1818);
    m_controller = MycroftController::instance();
    //TODO: delete
    m_view = new AbstractSkillView;
}

//TODO: test a spotty connection
void ServerTest::testGuiConnection()
{
    QSignalSpy newConnectionSpy(m_mainServerSocket, &QWebSocketServer::newConnection);
    QSignalSpy controllerSocketStatusChangedSpy(m_controller, &MycroftController::socketStatusChanged);
    m_controller->start();

    //wait the server received a connection and the client got connected state
    newConnectionSpy.wait();

    m_mainWebSocket = m_mainServerSocket->nextPendingConnection();
    QSignalSpy textFromMainSpy(m_mainWebSocket, &QWebSocket::textMessageReceived);
    QVERIFY(m_mainWebSocket);

    controllerSocketStatusChangedSpy.wait();
    QCOMPARE(m_controller->status(), MycroftController::Open);

    textFromMainSpy.wait();
    auto doc = QJsonDocument::fromJson(textFromMainSpy.first().first().toString().toLatin1());
    auto type = doc["type"].toString();
    auto guiId = doc["data"]["gui_id"].toString();

    QCOMPARE(type, QStringLiteral("mycroft.gui.connected"));
    QVERIFY(guiId.length() > 0);

    //Now, connect the gui
    QSignalSpy newGuiConnectionSpy(m_guiServerSocket, &QWebSocketServer::newConnection);
    m_mainWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.gui.port\", \"data\": {\"gui_id\": \"%1\", \"port\": 1818}}").arg(guiId));
    newGuiConnectionSpy.wait();
    m_guiWebSocket = m_guiServerSocket->nextPendingConnection();
    QVERIFY(m_guiWebSocket);
}

void ServerTest::testActiveSkills()
{
    QSignalSpy skillInsertedSpy(m_view->activeSkills(), &ActiveSkillsModel::rowsInserted);
    QSignalSpy skillMovedSpy(m_view->activeSkills(), &ActiveSkillsModel::rowsMoved);
    QSignalSpy skillRemovedSpy(m_view->activeSkills(), &ActiveSkillsModel::rowsRemoved);

    QCOMPARE(m_view->activeSkills()->rowCount(), 0);

    //Add weather skill
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.insert\", \"namespace\": \"mycroft.system.active_skills\", \"position\": 0, \"data\": [{\"skill_id\": \"mycroft.weather\"}]}"));

    skillInsertedSpy.wait();

    QCOMPARE(m_view->activeSkills()->rowCount(), 1);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("mycroft.weather"));

    //Add food-wizard skill, before weather
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.insert\", \"namespace\": \"mycroft.system.active_skills\", \"position\": 0, \"data\": [{\"skill_id\": \"aiix.food-wizard\"}]}"));

    skillInsertedSpy.wait();

    QCOMPARE(m_view->activeSkills()->rowCount(), 2);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("aiix.food-wizard"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(1,0)), QStringLiteral("mycroft.weather"));

    //Add timer skill, between food-wizard and weather
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.insert\", \"namespace\": \"mycroft.system.active_skills\", \"position\": 1, \"data\": [{\"skill_id\": \"mycroft.timer\"}]}"));

    skillInsertedSpy.wait();

    QCOMPARE(m_view->activeSkills()->rowCount(), 3);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("aiix.food-wizard"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(1,0)), QStringLiteral("mycroft.timer"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(2,0)), QStringLiteral("mycroft.weather"));

    //Add shopping skill, wiki and weather in the end: weather will be ignored as is already present
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.insert\", \"namespace\": \"mycroft.system.active_skills\", \"position\": 3, \"data\": [{\"skill_id\": \"aiix.shopping-demo\"}, {\"skill_id\": \"mycroft.wiki\"}, {\"skill_id\": \"mycroft.weather\"}]}"));

    skillInsertedSpy.wait();

    //5 because weather was ignored
    QCOMPARE(m_view->activeSkills()->rowCount(), 5);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("aiix.food-wizard"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(1,0)), QStringLiteral("mycroft.timer"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(2,0)), QStringLiteral("mycroft.weather"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(3,0)), QStringLiteral("aiix.shopping-demo"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(4,0)), QStringLiteral("mycroft.wiki"));

    //Move timer in first position
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.move\", \"namespace\": \"mycroft.system.active_skills\", \"from\": 2, \"to\": 1, \"items_number\": 1}"));

    skillMovedSpy.wait();

    QCOMPARE(m_view->activeSkills()->rowCount(), 5);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("aiix.food-wizard"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(1,0)), QStringLiteral("mycroft.weather"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(2,0)), QStringLiteral("mycroft.timer"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(3,0)), QStringLiteral("aiix.shopping-demo"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(4,0)), QStringLiteral("mycroft.wiki"));

    //Move weather and food-wizard in front
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.move\", \"namespace\": \"mycroft.system.active_skills\", \"from\": 1, \"to\": 0, \"items_number\": 2}"));

    skillMovedSpy.wait();

    QCOMPARE(m_view->activeSkills()->rowCount(), 5);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("mycroft.weather"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(1,0)), QStringLiteral("mycroft.timer"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(2,0)), QStringLiteral("aiix.food-wizard"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(3,0)), QStringLiteral("aiix.shopping-demo"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(4,0)), QStringLiteral("mycroft.wiki"));

    //Move timer and food-wizard in the back
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.move\", \"namespace\": \"mycroft.system.active_skills\", \"from\": 1, \"to\": 2, \"items_number\": 2}"));

    skillMovedSpy.wait();

    QCOMPARE(m_view->activeSkills()->rowCount(), 5);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("mycroft.weather"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(1,0)), QStringLiteral("aiix.shopping-demo"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(2,0)), QStringLiteral("mycroft.timer"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(3,0)), QStringLiteral("aiix.food-wizard"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(4,0)), QStringLiteral("mycroft.wiki"));

    //Remove shopping-demo and timer
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.remove\", \"namespace\": \"mycroft.system.active_skills\", \"position\": 1, \"items_number\": 2}"));

    skillRemovedSpy.wait();

    QCOMPARE(m_view->activeSkills()->rowCount(), 3);
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(0,0)), QStringLiteral("mycroft.weather"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(1,0)), QStringLiteral("aiix.food-wizard"));
    QCOMPARE(m_view->activeSkills()->data(m_view->activeSkills()->index(2,0)), QStringLiteral("mycroft.wiki"));
}

void ServerTest::testSessionData()
{
    QQmlPropertyMap *map = m_view->sessionDataForSkill("mycroft.weather");
    QVERIFY(map);
    QVERIFY(!m_view->sessionDataForSkill("invalidskillid"));

    QSignalSpy dataChangedSpy(map, &QQmlPropertyMap::valueChanged);

    //Add weather skill
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.set\", \"namespace\": \"mycroft.weather\", \"data\": {\"temperature\": \"28°C\", \"icon\": \"sunny\"}}"));

    dataChangedSpy.wait();
    QCOMPARE(dataChangedSpy.count(), 2);

    QCOMPARE(map->keys(), QStringList({"temperature", "icon"}));
    QCOMPARE(map->value("temperature"), "28°C");
    QCOMPARE(map->value("icon"), "sunny");
}

void ServerTest::testShowGui()
{
    QSignalSpy skillModelDataChangedSpy(m_view->activeSkills(), &ActiveSkillsModel::dataChanged);

    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.gui.show\", \"namespace\": \"mycroft.weather\", \"gui_url\": \"file://") + QFINDTESTDATA("currentweather.qml").toLatin1() + QStringLiteral("\"}"));

    skillModelDataChangedSpy.wait();
}

QTEST_MAIN(ServerTest);

#include "servertest.moc"
