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

#include "applicationsmodel.h"

#include <KRun>
#include <KService>
#include <KServiceGroup>

ApplicationsModel::ApplicationsModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

ApplicationsModel::~ApplicationsModel() = default;

QVariant ApplicationsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_data.count()) {
        return QVariant();
    }

    const auto &item = m_data.at(index.row());

    switch (role) {
    case Qt::DisplayRole: return item.service->name();
    case Qt::DecorationRole: return item.service->icon();
    }

    return QVariant();
}

int ApplicationsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_data.count();
}

QHash<int, QByteArray> ApplicationsModel::roleNames() const
{
    return QAbstractListModel::roleNames();
}

void ApplicationsModel::reload()
{
    QVector<ApplicationEntry> newItems;

    const auto group = KServiceGroup::group(QStringLiteral("Mycroft/")); // TODO configurable name
    if (!group) {
        return;
    }

    const auto items = group->entries(true /* sorted */,
                                      true /* excludeNoDisplay */,
                                      false /* allowSeparators */,
                                      false /* sortByGenericName */);
    newItems.reserve(items.count());

    for (const auto &item : items) {
        const KService::Ptr service(static_cast<KService*>(item.data())); // KSycocaEntry does not have "icon()"
        if (!service || !service->isValid()) {
            continue;
        }

        ApplicationEntry entry{
            service
        };

        newItems.append(entry);
    }

    beginResetModel();
    m_data = newItems;
    endResetModel();
}

void ApplicationsModel::launch(int row)
{
    if (row < 0 || row >= m_data.count()) {
        return;
    }

    const auto service = m_data.at(row).service;
    if (!service || !service->isValid()) {
        return;
    }

    KRun::runApplication(*service, {}, nullptr, KRun::DeleteTemporaryFiles, {}/*, KStartupInfo::createNewStartupIdForTimestamp(timeStamp)*/);

    /*KActivities::ResourceInstance::notifyAccessed(QUrl(QStringLiteral("applications:") + service->storageId()),
        QStringLiteral("org.kde.mycroft.launcher"));*/
}
