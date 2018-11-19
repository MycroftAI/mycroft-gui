/*
 * Copyright 2018 Kai Uwe Broulik <kde@broulik.de>
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

#include <KService>

struct ApplicationEntry
{
    KService::Ptr service;
};
Q_DECLARE_TYPEINFO(ApplicationEntry, Q_MOVABLE_TYPE);

class ApplicationsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit ApplicationsModel(QObject *parent);
    ~ApplicationsModel() override;

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    void reload();

    Q_INVOKABLE void launch(int row);

private:
    QVector<ApplicationEntry> m_data;

};
