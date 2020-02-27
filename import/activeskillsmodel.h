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
#include <QSortFilterProxyModel>

class AbstractDelegate;
class DelegatesModel;

class ActiveSkillsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int activeIndex READ activeIndex NOTIFY activeIndexChanged)
    Q_PROPERTY(QStringList blackList READ blackList WRITE setBlackList NOTIFY blackListChanged)
    Q_PROPERTY(QStringList whiteList READ whiteList WRITE setWhiteList NOTIFY whiteListChanged)

public:
    enum Roles {
        SkillId = Qt::UserRole + 1,
        Delegates
    };

    explicit ActiveSkillsModel(QObject *parent = nullptr);
    virtual ~ActiveSkillsModel();

    int activeIndex() const;

    QStringList blackList() const;
    void setBlackList(const QStringList &list);

    QStringList whiteList() const;
    void setWhiteList(const QStringList &list);

    void checkGuiActivation(const QString &skillId);
    bool skillAllowed(const QString skillId) const;

    /**
     * Insert new skills in the model, at a given position
     */
    void insertSkills(int position, const QStringList &skillList);

    /**
     * @returns the index for a skill, an invalid QModelIndex() if not found
     */
    QModelIndex skillIndex(const QString &skillId);

    QStringList activeSkills() const;

    DelegatesModel *delegatesModelForSkill(const QString &skillId);
    QHash<QString, DelegatesModel*> delegatesModels() const;

//REIMPLEMENTED
    bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = SkillId) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void activeIndexChanged();
    void blackListChanged();
    void whiteListChanged();
    void skillActivated(const QString &skillId);
    void blacklistedSkillActivated(const QString &skillId);

private:
    void syncActiveIndex();
    int m_activeIndex = -1;
    QList<QString> m_skills;
    QList<QString> m_blackList;
    QList<QString> m_whiteList;
    //TODO
    QHash<QString, DelegatesModel*> m_delegatesModels;
};


