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

#pragma once

#include <QAbstractListModel>

class AbstractDelegate;
class DelegatesModel;

class ActiveSkillsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        SkillId = Qt::UserRole + 1,
        Delegates
    };

    explicit ActiveSkillsModel(QObject *parent = nullptr);
    virtual ~ActiveSkillsModel();

    /**
     * Insert new skills in the model, at a given position
     */
    void insertSkills(int position, const QStringList &skillList);

    /**
     * @returns the index for a skill, an invalid QModelIndex() if not found
     */
    QModelIndex skillIndex(const QString &skillId);

    /**
     * @returns the delegate if any that corresponds to a particular skill and QML url
     */
    AbstractDelegate *delegateForSkill(const QString &skillId, const QUrl &qmlUrl) const;

    /**
     * Adds to the bookeeping a new delegate corresponding to a given skill
     */
    void insertDelegates(QList<AbstractDelegate *>delegates);

    /**
     * @returns all delegates existing for a given skill
     * @param skillId the skill we are searching delegates for.
     *                  If is an empty string all delegates will be returned.
     */
    QList<AbstractDelegate *> delegatesForSkill(const QString &skillId);

    DelegatesModel *delegatesModelForSkill(const QString &skillId);

//REIMPLEMENTED
    bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = SkillId) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<QString> m_skills;
    //TODO
    QHash<QString, DelegatesModel*> m_delegatesModels;
};


