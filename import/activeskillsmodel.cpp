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

#include "activeskillsmodel.h"
#include "delegatesmodel.h"

#include <QDebug>

ActiveSkillsModel::ActiveSkillsModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

ActiveSkillsModel::~ActiveSkillsModel()
{
    //TODO: delete everything
}

void ActiveSkillsModel::insertSkills(int position, const QStringList &skillList)
{
    QStringList filteredList;

    std::copy_if(skillList.begin(), skillList.end(),
                 std::back_inserter(filteredList),
                 [this](const QString &val)
                 {
                     return !m_skills.contains(val);
                 });

    if (filteredList.isEmpty()) {
        return;
    }

    beginInsertRows(QModelIndex(), qMax(0, position), qMin(m_skills.count(), position+ filteredList.count() - 1));
    int i = 0;
    for (const auto &skillId : filteredList) {
        m_skills.insert(position + i, skillId);
        ++i;
    }
    endInsertRows();
}

bool ActiveSkillsModel::moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild)
{
    if (sourceParent.isValid() || destinationParent.isValid()) {
        return false;
    }

    if (count <= 0 || sourceRow == destinationChild || sourceRow < 0 || sourceRow >= m_skills.count() ||
        destinationChild < 0 || destinationChild >= m_skills.count() || count - destinationChild > m_skills.count() - sourceRow) {
        return false;
    }
    const int sourceLast = sourceRow + count - 1;

    //beginMoveRows wants indexes before the source rows are removed from the old order
    if (!beginMoveRows(sourceParent, sourceRow, sourceLast, destinationParent, destinationChild + (sourceRow < destinationChild ? count : 0))) {
        return false;
    }

    if (sourceRow < destinationChild) {
        for (int i = count - 1; i >= 0; --i) {
            m_skills.move(sourceRow + i, destinationChild + i);
        }
    } else {
        for (int i = 0; i < count; ++i) {
            m_skills.move(sourceRow + i, destinationChild + i);
        }
    }

    endMoveRows();
}

bool ActiveSkillsModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row <= 0 || count <= 0 || row + count >= m_skills.count() || parent.isValid()) {
        return false;
    }

    beginRemoveRows(parent, row, row + count - 1);
    m_skills.erase(m_skills.begin() + row, m_skills.begin() + row + count);
    endRemoveRows();
}


int ActiveSkillsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_skills.count();
}

QVariant ActiveSkillsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    const int row = index.row();

    if (row < 0 || row >= m_skills.count() || (role != SkillId && role != Delegates)) {
        return QVariant();
    }

    //TODO: other roles
    return m_skills[row];
}

QHash<int, QByteArray> ActiveSkillsModel::roleNames() const
{
    return {
        {SkillId, "skillId"},
        {Delegates, "delegates"}
    };
}

