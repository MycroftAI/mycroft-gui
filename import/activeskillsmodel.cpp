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

void ActiveSkillsModel::syncActiveIndex()
{
    if (m_skills.isEmpty()) {
        m_activeIndex = -1;
        emit activeIndexChanged();
    }

    int index = -1;
    int i = 0;
    for (const auto &skill : m_skills) {

        if (skillAllowed(skill)) {
            index = i;
            break;
        }
        ++i;
    }

    if (m_activeIndex != index) {
        m_activeIndex = index;
        emit activeIndexChanged();
    }
}

int ActiveSkillsModel::activeIndex() const
{
    return m_activeIndex;
}


QStringList ActiveSkillsModel::blackList() const
{
    return m_blackList;
}

void ActiveSkillsModel::setBlackList(const QStringList &list)
{
    if (list == m_blackList) {
        return;
    }

    m_blackList = list;

    // TODO: delete/create delegates?
    emit blackListChanged();
}

QStringList ActiveSkillsModel::whiteList() const
{
    return m_whiteList;
}

void ActiveSkillsModel::setWhiteList(const QStringList &list)
{
    if (list == m_whiteList) {
        return;
    }

    m_whiteList = list;

    emit whiteListChanged();
}

void ActiveSkillsModel::checkGuiActivation(const QString &skillId)
{
    if (!skillAllowed(skillId)) {
        emit blacklistedSkillActivated(skillId);
        return;
    }

    if (activeSkills().isEmpty()) {
        return;
    }

    if (activeSkills().first() == skillId) {
        emit skillActivated(skillId);
    }
}

bool ActiveSkillsModel::skillAllowed(const QString skillId) const
{
    return !m_blackList.contains(skillId) && (m_whiteList.isEmpty() || m_whiteList.contains(skillId));
}

void ActiveSkillsModel::insertSkills(int position, const QStringList &skillList)
{
    if (position < 0 || position > m_skills.count()) {
        return;
    }

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

    beginInsertRows(QModelIndex(), position, position + filteredList.count() - 1);

    int i = 0;
    for (const auto &skillId : filteredList) {
        m_skills.insert(position + i, skillId);
        ++i;
    }
    //First syncactiveindex then endInserRows as it could make the view think we don't have any delegates for current skill
    syncActiveIndex();
    endInsertRows();

    //TODO: activate proper skills
    if (position == m_activeIndex) {
        checkGuiActivation(filteredList.first());
    }
}

QStringList ActiveSkillsModel::activeSkills() const
{
    return m_skills;
}

QModelIndex ActiveSkillsModel::skillIndex(const QString &skillId)
{
    const int row = m_skills.indexOf(skillId);

    if (row >= 0) {
        return index(row, 0, QModelIndex());
    }

    return QModelIndex();
}

DelegatesModel *ActiveSkillsModel::delegatesModelForSkill(const QString &skillId)
{

    if (!skillAllowed(skillId)) {
        return nullptr;
    }

    if (!skillId.isEmpty() && !m_skills.contains(skillId)) {
        return nullptr;
    }

    DelegatesModel *model = m_delegatesModels.value(skillId);
    if (!model) {
        model = new DelegatesModel(this);
        m_delegatesModels[skillId] = model;
        const int row = m_skills.indexOf(skillId);
        emit dataChanged(index(row, 0), index(row, 0), {Delegates});
    }

    return model;
}

QHash<QString, DelegatesModel*> ActiveSkillsModel::delegatesModels() const
{
    return m_delegatesModels;
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
    if (!beginMoveRows(sourceParent, sourceRow, sourceLast, destinationParent, destinationChild)) {
        return false;
    }

    if (sourceRow < destinationChild) {
        for (int i = count - 1; i >= 0; --i) {
            m_skills.move(sourceRow + i, destinationChild - count + i);
        }
    } else {
        for (int i = 0; i < count; ++i) {
            m_skills.move(sourceRow + i, destinationChild + i);
        }
    }

    endMoveRows();

    syncActiveIndex();
    if (destinationChild == m_activeIndex) {
        checkGuiActivation(m_skills.first());
    }

    return true;
}

bool ActiveSkillsModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || count <= 0 || row + count > m_skills.count() || parent.isValid()) {
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
    syncActiveIndex();
    return true;
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

