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

    AbstractDelegate *delegateForSkill(const QString &skillId, const QUrl &qmlUrl) const;
    void insertDelegateForSkill(const QString &skillId, AbstractDelegate *delegate);

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


