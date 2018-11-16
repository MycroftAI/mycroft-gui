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

#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QUrl>

class AbstractDelegate;

class DelegatesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex MEMBER m_currentIndex NOTIFY currentIndexChanged)

public:
    enum Roles {
        DelegateUi = Qt::UserRole + 1,
    };

    explicit DelegatesModel(QObject *parent = nullptr);
    virtual ~DelegatesModel();

    /**
     * Insert a delegate after currentIndex
     * TODO: more fine grained control on position?
     */
    void insertDelegate(AbstractDelegate *delegate);

    /**
     * clears the whole model
     */
    void clear();

    /**
     * @returns the delegate generated with the given qml file url, if any
     */
    AbstractDelegate *delegateForUrl(const QUrl &url);

    bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = DelegateUi) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void currentIndexChanged();

private:
    QList<AbstractDelegate *> m_delegates;
    QHash<QUrl, AbstractDelegate *> m_delegateForUrl;
    int m_currentIndex;
};
