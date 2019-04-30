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

#include <QTimer>
#include <QDebug>


DelegatesModel::DelegatesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_deleteTimer = new QTimer(this);
    m_deleteTimer->setSingleShot(true);
    m_deleteTimer->setInterval(2000);

    connect(m_deleteTimer, &QTimer::timeout, this, [this]() {
        for (auto d : m_delegateLoadersToDelete) {
            d->deleteLater();
        }
        m_delegateLoadersToDelete.clear();
    });
}

DelegatesModel::~DelegatesModel()
{
    //TODO: necessary?
    for (auto c : m_delegateLoadersToDelete) {
        c->deleteLater();
    }
    for (auto c : m_delegateLoaders) {
        c->deleteLater();
    }
}

void DelegatesModel::insertDelegateLoaders(int position, QList<DelegateLoader *> loaders)
{
    if (position < 0 || position > m_delegateLoaders.count()) {
        return;
    }

    beginInsertRows(QModelIndex(), position, position + loaders.count() - 1);

    int i = 0;
    for (auto *loader : loaders) {
        m_delegateLoaders.insert(position + i, loader);
        if (!loader->delegate()) {
            connect(loader, &DelegateLoader::delegateCreated, this, [this, loader]() {
                int row = m_delegateLoaders.indexOf(loader);
                emit dataChanged(index(row, 0), index(row, 0), {DelegateUi});
            });
        }
        connect(loader, &QObject::destroyed, this, [this](QObject *obj) {
            const int index = m_delegateLoaders.indexOf(qobject_cast<DelegateLoader *>(obj));
            //if the loader is in the list, remove it
            if (index > -1) {
                removeRows(index, 1, QModelIndex());
            }
        });
        ++i;
    }

    endInsertRows();

    m_currentIndex = m_delegateLoaders.indexOf(loaders.first());
    emit currentIndexChanged();
}

void DelegatesModel::clear()
{
    
    beginResetModel();
    m_delegateLoadersToDelete = m_delegateLoaders;
    m_deleteTimer->start();
    m_delegateLoaders.clear();
    endResetModel();
}

QList<AbstractDelegate *> DelegatesModel::delegates() const
{
    QList<AbstractDelegate *> delegates;

    for (auto c : m_delegateLoaders) {
        if (c->delegate()) {
            delegates << c->delegate();
        }
    }

    return delegates;
}

bool DelegatesModel::moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild)
{
    if (sourceParent.isValid() || destinationParent.isValid()) {
        return false;
    }

    if (count <= 0 || sourceRow == destinationChild || sourceRow < 0 || sourceRow >= m_delegateLoaders.count() ||
        destinationChild < 0 || destinationChild >= m_delegateLoaders.count() || count - destinationChild > m_delegateLoaders.count() - sourceRow) {
        return false;
    }
    const int sourceLast = sourceRow + count - 1;

    //beginMoveRows wants indexes before the source rows are removed from the old order
    if (!beginMoveRows(sourceParent, sourceRow, sourceLast, destinationParent, destinationChild)) {
        return false;
    }

    if (sourceRow < destinationChild) {
        for (int i = count - 1; i >= 0; --i) {
            m_delegateLoaders.move(sourceRow + i, qMin(destinationChild + i, m_delegateLoaders.count() - 1));
        }
    } else {
        for (int i = 0; i < count; ++i) {
            m_delegateLoaders.move(sourceRow + i, destinationChild + i);
        }
    }

    endMoveRows();
    return true;
}

bool DelegatesModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || count <= 0 || row + count > m_delegateLoaders.count() || parent.isValid()) {
        return false;
    }

    beginRemoveRows(parent, row, row + count - 1);
    std::copy(m_delegateLoaders.begin() + row, m_delegateLoaders.begin() + row + count,
              std::back_inserter(m_delegateLoadersToDelete));
    m_deleteTimer->start();
    m_delegateLoaders.erase(m_delegateLoaders.begin() + row, m_delegateLoaders.begin() + row + count);

    endRemoveRows();
    return true;
}


int DelegatesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_delegateLoaders.count();
}

QVariant DelegatesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.parent().isValid()) {
        return QVariant();
    }
    const int row = index.row();

    if (row < 0 || row >= m_delegateLoaders.count() || role != DelegateUi) {
        return QVariant();
    }

    return QVariant::fromValue(m_delegateLoaders[row]->delegate());
}

QHash<int, QByteArray> DelegatesModel::roleNames() const
{
    return {
        {DelegateUi, "delegateUi"}
    };
}

