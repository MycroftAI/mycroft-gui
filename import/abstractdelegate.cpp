/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
 *   Copyright 2018 David Edmundson <davidedmundson@kde.org>
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

#include "abstractdelegate.h"
#include "mycroftcontroller.h"

AbstractDelegate::AbstractDelegate(QQuickItem *parent)
    : QQuickItem(parent)
{
}

AbstractDelegate::~AbstractDelegate()
{
}

void AbstractDelegate::setSessionData(QQmlPropertyMap *data)
{
    //possible to call only once, by the skillview upon instantiation
    Q_ASSERT(!m_data);
    m_data = data;
}

QQmlPropertyMap *AbstractDelegate::sessionData() const
{
    return m_data;
}

void AbstractDelegate::setQmlUrl(const QUrl &url)
{
    Q_ASSERT(m_qmlUrl.isEmpty());
    m_qmlUrl = url;
}

QUrl AbstractDelegate::qmlUrl() const
{
    return m_qmlUrl;
}

#include "moc_abstractdelegate.cpp"
