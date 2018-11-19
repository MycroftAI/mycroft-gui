/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
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

#include <QtTest>
#include <QWebSocket>
#include <QWebSocketServer>
#include <QAbstractItemModel>
#include "../import/mycroftcontroller.h"
#include "../import/abstractdelegate.h"
#include "../import/activeskillsmodel.h"
#include "../import/delegatesmodel.h"
#include "../import/abstractskillview.h"
#include "../import/sessiondatamap.h"

class ServerTest : public QObject
{
    Q_OBJECT

public Q_SLOTS:
    void initTestCase();

private Q_SLOTS:
    void testGuiConnection();
    void testActiveSkills();
    void testSessionData();
    void testChangeSessionData();
    void testShowGui();
    void testEventsFromServer();

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
    auto type = doc[QStringLiteral("type")].toString();
    auto guiId = doc[QStringLiteral("data")][QStringLiteral("gui_id")].toString();

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
    SessionDataMap *map = m_view->sessionDataForSkill(QStringLiteral("mycroft.weather"));
    QVERIFY(map);
    //No sessiondata for invalid skills
    QVERIFY(!m_view->sessionDataForSkill(QStringLiteral("invalidskillid")));

    QSignalSpy dataChangedSpy(map, &SessionDataMap::valueChanged);

    //set data for weather skill
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.set\", \"namespace\": \"mycroft.weather\", \"data\": {\"temperature\": \"28°C\", \"icon\": \"sunny\"}}"));

    dataChangedSpy.wait();
    QCOMPARE(dataChangedSpy.count(), 2);

    QCOMPARE(map->keys().count(), 2);
    QCOMPARE(map->value(QStringLiteral("temperature")), QStringLiteral("28°C"));
    QCOMPARE(map->value(QStringLiteral("icon")), QStringLiteral("sunny"));
}

void ServerTest::testChangeSessionData()
{
    SessionDataMap *map = m_view->sessionDataForSkill(QStringLiteral("mycroft.weather"));
    QVERIFY(map);
    QVERIFY(!m_view->sessionDataForSkill(QStringLiteral("invalidskillid")));

    QSignalSpy dataChangedSpy(map, &SessionDataMap::valueChanged);
    QSignalSpy dataClearedSpy(map, &SessionDataMap::dataCleared);

    //set data for weather skill
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.set\", \"namespace\": \"mycroft.weather\", \"data\": {\"temperature\": \"24°C\", \"otherproperty\": \"value\"}}"));

    dataChangedSpy.wait();
    QCOMPARE(dataChangedSpy.count(), 2);

    //keys are alphabetically ordered
    QCOMPARE(map->keys().count(), 3);
    QCOMPARE(map->value(QStringLiteral("temperature")), QStringLiteral("24°C"));
    QCOMPARE(map->value(QStringLiteral("icon")), QStringLiteral("sunny"));
    QCOMPARE(map->value(QStringLiteral("otherproperty")), QStringLiteral("value"));

    //remove otherproperty
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.session.delete\", \"namespace\": \"mycroft.weather\", \"property\": \"otherproperty\"}"));

    dataClearedSpy.wait();
    QCOMPARE(dataClearedSpy.first().first(), QStringLiteral("otherproperty"));
    //is not possible to actually remove a key
    QCOMPARE(map->keys().count(), 3);
    QCOMPARE(map->value(QStringLiteral("temperature")), QStringLiteral("24°C"));
    QCOMPARE(map->value(QStringLiteral("icon")), QStringLiteral("sunny"));
    QCOMPARE(map->value(QStringLiteral("otherproperty")), QVariant());
}

void ServerTest::testShowGui()
{
    QSignalSpy skillModelDataChangedSpy(m_view->activeSkills(), &ActiveSkillsModel::dataChanged);

    const QUrl url(QStringLiteral("file://") + QFINDTESTDATA("currentweather.qml"));

    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.gui.show\", \"namespace\": \"mycroft.weather\", \"gui_url\": \"") + url.toString() + QStringLiteral("\"}"));

    skillModelDataChangedSpy.wait();

    AbstractDelegate *delegate = m_view->activeSkills()->delegateForSkill(QStringLiteral("mycroft.weather"), url);
    QVERIFY(delegate);
    QCOMPARE(delegate->skillId(), QStringLiteral("mycroft.weather"));
    QCOMPARE(delegate->qmlUrl(), url);

    //check the delegate has the proper data associated
    SessionDataMap *map = delegate->sessionData();
    QVERIFY(map);
    QCOMPARE(map->keys().count(), 3);
    QCOMPARE(map->value(QStringLiteral("temperature")), QStringLiteral("24°C"));
    QCOMPARE(map->value(QStringLiteral("icon")), QStringLiteral("sunny"));
    QCOMPARE(map->value(QStringLiteral("otherproperty")), QVariant());

    //try to get the delegate via the model, like qml will do and check they're the same
    DelegatesModel *dm = m_view->activeSkills()->data(m_view->activeSkills()->index(0, 0), ActiveSkillsModel::Delegates).value<DelegatesModel *>();
    QVERIFY(dm);
    AbstractDelegate *delegate2 = dm->data(dm->index(0, 0), DelegatesModel::DelegateUi).value<AbstractDelegate *>();
    QCOMPARE(delegate, delegate2);
}

void ServerTest::testEventsFromServer()
{
    AbstractDelegate *delegate = m_view->activeSkills()->delegatesForSkill(QStringLiteral("mycroft.weather")).first();
    QVERIFY(delegate);
    QCOMPARE(delegate->skillId(), QStringLiteral("mycroft.weather"));

    QSignalSpy eventSpy(delegate, &AbstractDelegate::event);

    //An event of the weather skill
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.events.triggered\", \"namespace\": \"mycroft.weather\", \"event_name\": \"show_alert\", \"data\": {\"alert_name\": \"blizzard\", \"condition\": \"severe\"}}"));

    eventSpy.wait();
    QCOMPARE(eventSpy.count(), 1);
    QCOMPARE(eventSpy.first().first(), QStringLiteral("show_alert"));
    QCOMPARE(eventSpy.first()[1].value<QVariantMap>()[QStringLiteral("alert_name")], QStringLiteral("blizzard"));
    QCOMPARE(eventSpy.first()[1].value<QVariantMap>()[QStringLiteral("condition")], QStringLiteral("severe"));

    //A system event
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.events.triggered\", \"namespace\": \"system\", \"event_name\": \"system.next\", \"data\": {}}"));

    eventSpy.wait();
    QCOMPARE(eventSpy.count(), 2);
    QCOMPARE(eventSpy[1].first(), QStringLiteral("system.next"));

    //An event for the wiki skill: the weather one will never receive it
    m_guiWebSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.events.triggered\", \"namespace\": \"mycroft.wiki\", \"event_name\": \"new_data\", \"data\": {}}"));

    eventSpy.wait(1000);
    QCOMPARE(eventSpy.count(), 2);
}

QTEST_MAIN(ServerTest);

#include "servertest.moc"
