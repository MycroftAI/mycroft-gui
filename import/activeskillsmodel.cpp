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

#include "activeskillsmodel.h"

#include <QDebug>
#include <QStandardItemModel>

ActiveSkillsModel::ActiveSkillsModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

ActiveSkillsModel::~ActiveSkillsModel()
{
    //TODO: delete everything
}

int ActiveSkillsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data.count();
}

QVariant ActiveSkillsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    const int row = index.row();

    if (row < 0 || row > m_data.count() || !m_data[index.row()].contains(role)) {
        return QVariant();
    }

    return m_data[index.row()][role];

    return QVariant();
}

QHash<int, QByteArray> ActiveSkillsModel::roleNames() const
{
    return {
        {SkillId, "skillId"},
        {GuiModel, "guiModel"}
    };
}

