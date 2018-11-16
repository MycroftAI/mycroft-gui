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

#include "delegatesmodel.h"
#include "abstractdelegate.h"

#include <QDebug>


DelegatesModel::DelegatesModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

DelegatesModel::~DelegatesModel()
{
    //TODO: delete everything?
}

void DelegatesModel::insertDelegate(AbstractDelegate *delegate)
{
    if (m_delegates.contains(delegate) || m_delegateForUrl.contains(delegate->qmlUrl())) {
        return;
    }

    beginInsertRows(QModelIndex(), qMax(0, m_currentIndex), qMin(m_delegates.count(), m_currentIndex));
    int i = 0;
    m_delegates.insert(m_currentIndex, delegate);
    m_delegateForUrl.insert(delegate->qmlUrl(), delegate);

    endInsertRows();
}

void DelegatesModel::clear()
{
    beginResetModel();
    //TODO: how is the ownership? should we delete them at all or should be QML?
    //if we delete them, after a timeout to give it time to animate?
    for (auto *delegate : m_delegates) {
        delegate->deleteLater();
    }
    m_delegates.clear();
    m_delegateForUrl.clear();
    endResetModel();
}

AbstractDelegate *DelegatesModel::delegateForUrl(const QUrl &url)
{
    return m_delegateForUrl.value(url);
}

bool DelegatesModel::moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild)
{
    if (sourceParent.isValid() || destinationParent.isValid()) {
        return false;
    }

    if (count <= 0 || sourceRow == destinationChild || sourceRow < 0 || sourceRow >= m_delegates.count() ||
        destinationChild < 0 || destinationChild >= m_delegates.count() || count - destinationChild > m_delegates.count() - sourceRow) {
        return false;
    }
    const int sourceLast = sourceRow + count - 1;

    //beginMoveRows wants indexes before the source rows are removed from the old order
    if (!beginMoveRows(sourceParent, sourceRow, sourceLast, destinationParent, destinationChild + (sourceRow < destinationChild ? count : 0))) {
        return false;
    }

    if (sourceRow < destinationChild) {
        for (int i = count - 1; i >= 0; --i) {
            m_delegates.move(sourceRow + i, destinationChild + i);
        }
    } else {
        for (int i = 0; i < count; ++i) {
            m_delegates.move(sourceRow + i, destinationChild + i);
        }
    }

    endMoveRows();
}

bool DelegatesModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row <= 0 || count <= 0 || row + count >= m_delegates.count() || parent.isValid()) {
        return false;
    }

    beginRemoveRows(parent, row, row + count - 1);
    QList<AbstractDelegate *> toDelete;
    std::copy(m_delegates.begin() + row, m_delegates.begin() + row + count,
              std::back_inserter(toDelete));
    m_delegates.erase(m_delegates.begin() + row, m_delegates.begin() + row + count);
    //TODO: how is the ownership? should we delete them at all or should be QML?
    //if we delete them, after a timeout to give it time to animate?
    for (auto *delegate : toDelete) {
        m_delegateForUrl.remove(delegate->qmlUrl());
        delegate->deleteLater();
    }
    endRemoveRows();
}


int DelegatesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_delegates.count();
}

QVariant DelegatesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.parent().isValid()) {
        return QVariant();
    }
    const int row = index.row();

    if (row < 0 || row >= m_delegates.count() || role != DelegateUi) {
        return QVariant();
    }

    return QVariant::fromValue(m_delegates[row]);
}

QHash<int, QByteArray> DelegatesModel::roleNames() const
{
    return {
        {DelegateUi, "delegateUi"}
    };
}

