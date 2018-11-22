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

//FIXME: This implementation is very inefficient, if will take too much of a toll a more efficient one must be found
//TODO: this needs extensive autotesting
void DelegatesModel::insertDelegates(QList<AbstractDelegate *> delegates)
{
    //some of the delegates may already be present, the model must generate rowsInserted for the actually new ones, and rowsModed for the ones already present, moving them at the right new position
    QList<AbstractDelegate *> missingDelegates;
    QList<AbstractDelegate *> presentDelegates;

    for (auto *delegate : delegates) {
        if (m_delegates.contains(delegate)) {
            presentDelegates << delegate;
        } else {
            missingDelegates << delegate;
        }
    }

    const int startPos = qMax(0, qMin(m_currentIndex + 1, m_delegates.count()));

    if (!missingDelegates.isEmpty()) {

        beginInsertRows(QModelIndex(), startPos, startPos + missingDelegates.count() - 1);

        int i = 0;
        for (auto *delegate : missingDelegates) {
            m_delegates.insert(startPos + i, delegate);
            connect(delegate, &QObject::destroyed, this, [this](QObject *obj) {
                const int index = m_delegates.indexOf(qobject_cast<AbstractDelegate *>(obj));
                //if the delegate is in the list, remove it
                if (index > -1) {
                    removeRows(index, 1, QModelIndex());
                }
            });
            m_delegateForUrl.insert(delegate->qmlUrl(), delegate);
            ++i;
        }

        endInsertRows();
    }

    if (!presentDelegates.isEmpty()) {
        int i = 0;
        for (auto *delegate : presentDelegates) {
            moveRows(QModelIndex(), m_delegates.indexOf(delegate), 1, QModelIndex(), startPos + i);
            ++i;
        }
    }

    m_currentIndex = m_delegates.indexOf(delegates.first());
    emit currentIndexChanged();
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

QList<AbstractDelegate *> DelegatesModel::delegates() const
{
    return m_delegates;
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
    if (!beginMoveRows(sourceParent, sourceRow, sourceLast, destinationParent, destinationChild)) {
        return false;
    }

    if (sourceRow < destinationChild) {
        for (int i = count - 1; i >= 0; --i) {
            m_delegates.move(sourceRow + i, qMin(destinationChild + i, m_delegates.count() - 1));
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
    if (row <= 0 || count <= 0 || row + count > m_delegates.count() || parent.isValid()) {
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

