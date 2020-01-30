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

#include "sessiondatamodel.h"

#include <QDebug>

SessionDataModel::SessionDataModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

SessionDataModel::~SessionDataModel()
{
    //TODO: delete everything
}

void SessionDataModel::insertData(int position, const QList<QVariantMap> &dataList)
{
    if (position < 0 || position > m_data.count()) {
        return;
    }
    if (dataList.isEmpty()) {
        return;
    }

    // First insert: prepare role names
    // NOTE: the role names MUST stay fixed for the entire lifetime of the model object, if new roles are needed, a new model object must be created
    if (m_roles.isEmpty()) {
        int role = Qt::UserRole + 1;
        for (const auto &key : dataList.first().keys()) {
            m_roles[role] = key.toUtf8();
            ++role;
        }
    }

    beginInsertRows(QModelIndex(), position, position + dataList.count() - 1);
    int i = 0;
    for (const auto &item : dataList) {
        m_data.insert(position + i, item);
        ++i;
    }
    endInsertRows();
}

void SessionDataModel::updateData(int position, const QList<QVariantMap> &dataList)
{
    if (dataList.isEmpty()) {
        return;
    }
    //too much rows to update, we don't have enough
    if (m_data.count() - position < dataList.count()) {
        return;
    }

    QSet<int> roles;

    int i = 0;
    for (auto it = m_data.begin() + position; it < m_data.begin() + position + dataList.count(); ++it) {
        const QVariantMap newValues = dataList[i];
        for (auto newIt = newValues.begin(); newIt != newValues.end(); ++newIt) {
            (*it)[newIt.key()] = newIt.value();
            roles.insert(m_roles.key(newIt.key().toUtf8()));
        }
        ++i;
    }
    emit dataChanged(index(position, 0), index(position + dataList.length() - 1, 0), roles.values().toVector());
}

void SessionDataModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
}

bool SessionDataModel::moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild)
{
    if (sourceParent.isValid() || destinationParent.isValid()) {
        return false;
    }

    if (count <= 0 || sourceRow == destinationChild || sourceRow < 0 || sourceRow >= m_data.count() ||
        destinationChild < 0 || destinationChild > m_data.count() || count - destinationChild > m_data.count() - sourceRow) {
        return false;
    }
    const int sourceLast = sourceRow + count - 1;

    //beginMoveRows wants indexes before the source rows are removed from the old order
    if (!beginMoveRows(sourceParent, sourceRow, sourceLast, destinationParent, destinationChild)) {
        return false;
    }

    if (sourceRow < destinationChild) {
        for (int i = count - 1; i >= 0; --i) {
            m_data.move(sourceRow + i, destinationChild - count + i);
        }
    } else {
        for (int i = 0; i < count; ++i) {
            m_data.move(sourceRow + i, destinationChild + i);
        }
    }

    endMoveRows();
    return true;
}

bool SessionDataModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || count <= 0 || row + count > m_data.count() || parent.isValid()) {
        return false;
    }

    beginRemoveRows(parent, row, row + count - 1);

    m_data.erase(m_data.begin() + row, m_data.begin() + row + count);
    endRemoveRows();
    return true;
}


int SessionDataModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_data.count();
}

QVariant SessionDataModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    const int row = index.row();

    if (row < 0 || row >= m_data.count() || !m_roles.contains(role)) {
        return QVariant();
    }

    return m_data[row][QString::fromUtf8(m_roles[role])];
}

QHash<int, QByteArray> SessionDataModel::roleNames() const
{
    return m_roles;
}

