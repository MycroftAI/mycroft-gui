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

#include "activeskillsmodel.h"
#include "delegatesmodel.h"
#include "abstractdelegate.h"

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

QModelIndex ActiveSkillsModel::skillIndex(const QString &skillId)
{
    const int row = m_skills.indexOf(skillId);

    if (row >= 0) {
        return index(row, 0, QModelIndex());
    }

    return QModelIndex();
}

AbstractDelegate *ActiveSkillsModel::delegateForSkill(const QString &skillId, const QUrl &qmlUrl) const
{
    DelegatesModel *model = m_delegatesModels.value(skillId);
    if (!model) {
        return nullptr;
    }

    return model->delegateForUrl(qmlUrl);
}

void ActiveSkillsModel::insertDelegate(AbstractDelegate *delegate)
{
    if (!m_skills.contains(delegate->skillId())) {
        return;
    }

    DelegatesModel *model = m_delegatesModels.value(delegate->skillId());
    if (!model) {
        model = new DelegatesModel(this);
        m_delegatesModels[delegate->skillId()] = model;
        const int row = m_skills.indexOf(delegate->skillId());
        emit dataChanged(index(row, 0), index(row, 0), {Delegates});
    }

    model->insertDelegate(delegate);
}

QList<AbstractDelegate *> ActiveSkillsModel::delegatesForSkill(const QString &skillId)
{
    QList<AbstractDelegate *> list;

    if (!skillId.isEmpty() && !m_skills.contains(skillId)) {
        return list;
    }

    if (skillId.isEmpty()) {
        for (auto *model : m_delegatesModels.values()) {
            list << model->delegates();
        }
        return list;
    } else {
        DelegatesModel *model = m_delegatesModels.value(skillId);
        if (!model) {
            return list;
        }
        return model->delegates();
    }
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
    for (auto it = m_skills.begin() + row; it < m_skills.begin() + row + count; ++it) {
        DelegatesModel *model = m_delegatesModels.value(*it);
        if (model) {
            model->deleteLater();
            m_delegatesModels.remove(*it);
        }
    }
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

    if (role == SkillId) {
        return m_skills[row];
    //Delegates
    } else {
        return QVariant::fromValue(m_delegatesModels.value(m_skills[row]));
    }
}

QHash<int, QByteArray> ActiveSkillsModel::roleNames() const
{
    return {
        {SkillId, "skillId"},
        {Delegates, "delegates"}
    };
}

