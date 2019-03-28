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
#include <QHash>
#include <QUrl>

class QTimer;

class AbstractDelegate;
class DelegateLoader;

class DelegatesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex MEMBER m_currentIndex NOTIFY currentIndexChanged)

public:
    enum Roles {
        DelegateUi = Qt::UserRole + 1
    };

    explicit DelegatesModel(QObject *parent = nullptr);
    virtual ~DelegatesModel();

    /**
     * Insert one or more delegates at position
     */
    void insertDelegateLoaders(int position, QList<DelegateLoader *> loaders);

    /**
     * clears the whole model
     */
    void clear();

    /**
     * @returns the complete delegate set
     */
    QList<AbstractDelegate *> delegates() const;

    bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = DelegateUi) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void currentIndexChanged();

private:
    QList<DelegateLoader *> m_delegateLoaders;
    QList<DelegateLoader *> m_delegateLoadersToDelete;
    QTimer *m_deleteTimer;
    int m_currentIndex = 0;
};
