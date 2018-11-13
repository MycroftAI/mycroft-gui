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

#include <QtTest>
#include <QWebSocket>
#include <QWebSocketServer>
#include "../import/mycroftcontroller.h"
#include "../import/delegate.h"
#include "../import/activeskillsmodel.h"

class ServerTest : public QObject
{
    Q_OBJECT

public Q_SLOTS:
    void initTestCase();

private Q_SLOTS:
    void testConnection();

private:
    //Client
    MycroftController *m_controller;

    //Server
    QWebSocketServer *m_mainServerSocket;
    QWebSocketServer *m_guiServerSocket;
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
}

void ServerTest::testConnection()
{
    QSignalSpy newConnectionSpy(m_mainServerSocket, &QWebSocketServer::newConnection);
    QSignalSpy controllerSocketStatusChangedSpy(m_controller, &MycroftController::socketStatusChanged);
    m_controller->start();
    

    //wait the server received a connection and the client got connected state
    newConnectionSpy.wait();

    QWebSocket *mainSocket = m_mainServerSocket->nextPendingConnection();
    QSignalSpy textFromMainSpy(mainSocket, &QWebSocket::textMessageReceived);
    QVERIFY(mainSocket);

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
    mainSocket->sendTextMessage(QStringLiteral("{\"type\": \"mycroft.gui.port\", \"data\": {\"gui_id\": \"%1\", \"port\": 1818}}").arg(guiId));
    newGuiConnectionSpy.wait();

    
}


QTEST_MAIN(ServerTest);

#include "servertest.moc"
