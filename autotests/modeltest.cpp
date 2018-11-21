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
#include <QQuickView>
#include <QQmlEngine>
#include <QAbstractItemModelTester>
#include "../import/mycroftcontroller.h"
#include "../import/abstractdelegate.h"
#include "../import/filereader.h"
#include "../import/globalsettings.h"
#include "../import/activeskillsmodel.h"
#include "../import/delegatesmodel.h"
#include "../import/abstractskillview.h"
#include "../import/sessiondatamap.h"
#include "../import/sessiondatamodel.h"

class ModelTest : public QObject
{
    Q_OBJECT

public Q_SLOTS:
    void initTestCase();

private Q_SLOTS:
    void testActiveSkills();

private:
    ActiveSkillsModel *m_skillsModel;
};


void ModelTest::initTestCase()
{
    m_skillsModel = new ActiveSkillsModel(this);
}

//TODO: test a spotty connection
void ModelTest::testActiveSkills()
{
    new QAbstractItemModelTester(m_skillsModel, QAbstractItemModelTester::FailureReportingMode::QtTest, this);
    m_skillsModel->insertSkills(0, QStringList({QStringLiteral("skill0"), QStringLiteral("skill1"), QStringLiteral("skill2"), QStringLiteral("skill3")}));
    m_skillsModel->moveRows(QModelIndex(), 2, 1, QModelIndex(), 1);
    m_skillsModel->moveRows(QModelIndex(), 2, 2, QModelIndex(), 1);
    m_skillsModel->moveRows(QModelIndex(), 0, 2, QModelIndex(), 3);
    m_skillsModel->removeRows(1, 2);
    m_skillsModel->insertSkills(2, QStringList({QStringLiteral("newSkill")}));
}

QTEST_MAIN(ModelTest);

#include "modeltest.moc"
