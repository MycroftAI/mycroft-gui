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

class AbstractDelegate;
class DelegatesModel;

class SessionDataModel : public QAbstractListModel
{
    Q_OBJECT

public:

    explicit SessionDataModel(QObject *parent = nullptr);
    virtual ~SessionDataModel();

    /**
     * Insert new data in the model, at a given position
     */
    void insertData(int position, const QList<QVariantMap> &dataList);

    /**
     * update the value of items from position to dataList.count()
     * for each key contained in dataList.
     * keys not present will not be updated
     */
    void updateData(int position, const QList<QVariantMap> &dataList);

    /**
     * clears the whole model
     */
    void clear();

//REIMPLEMENTED
    bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::UserRole + 1) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QHash<int, QByteArray> m_roles;
    QList<QVariantMap> m_data;
};


