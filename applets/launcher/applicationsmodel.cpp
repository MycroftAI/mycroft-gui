/*
 * Copyright 2018 Kai Uwe Broulik <kde@broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
