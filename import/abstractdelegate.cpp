/*
 *   Copyright 2018 by Marco Martin <mart@kde.org>
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

#include "abstractdelegate.h"
#include "mycroftcontroller.h"

AbstractDelegate::AbstractDelegate(QQuickItem *parent)
    : QQuickItem(parent)
{
}

AbstractDelegate::~AbstractDelegate()
{
}

void AbstractDelegate::syncChildItemsGeometry(const QSizeF &size)
{
    if (m_contentItem) {
        m_contentItem->setX(m_leftPadding);
        m_contentItem->setY(m_topPadding);
        m_contentItem->setSize(QSizeF(size.width() - m_leftPadding - m_rightPadding,
                size.height() - m_topPadding - m_bottomPadding));
    }

    if (m_backgroundItem) {
        m_backgroundItem->setX(0);
        m_backgroundItem->setY(0);
        m_backgroundItem->setSize(size);
    }

}

void AbstractDelegate::contentData_append(QQmlListProperty<QObject> *prop, QObject *object)
{
    AbstractDelegate *delegate = static_cast<AbstractDelegate *>(prop->object);
    if (!delegate) {
        return;
    }

    QQuickItem *item = qobject_cast<QQuickItem *>(object);
    delegate->m_contentData.append(object);
    if (item) {
        if (!delegate->m_contentItem) {
            //qWarning()<<"Creting default contentItem";
            delegate->m_contentItem = new QQuickItem(delegate);
        }
        item->setParentItem(delegate->m_contentItem);
    }
}

int AbstractDelegate::contentData_count(QQmlListProperty<QObject> *prop)
{
    AbstractDelegate *delegate = static_cast<AbstractDelegate *>(prop->object);
    if (!delegate) {
        return 0;
    }

    return delegate->m_contentData.count();
}

QObject *AbstractDelegate::contentData_at(QQmlListProperty<QObject> *prop, int index)
{
    AbstractDelegate *delegate = static_cast<AbstractDelegate *>(prop->object);
    if (!delegate) {
        return nullptr;
    }

    if (index < 0 || index >= delegate->m_contentData.count()) {
        return nullptr;
    }
    return delegate->m_contentData.value(index);
}

void AbstractDelegate::contentData_clear(QQmlListProperty<QObject> *prop)
{
    AbstractDelegate *delegate = static_cast<AbstractDelegate *>(prop->object);
    if (!delegate) {
        return;
    }

    return delegate->m_contentData.clear();
}

QQmlListProperty<QObject> AbstractDelegate::contentData()
{
    return QQmlListProperty<QObject>(this, nullptr,
                                     contentData_append,
                                     contentData_count,
                                     contentData_at,
                                     contentData_clear);
}

void AbstractDelegate::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    syncChildItemsGeometry(newGeometry.size());
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

QQuickItem *AbstractDelegate::contentItem() const
{
    return m_contentItem;
}

void AbstractDelegate::setContentItem(QQuickItem *item)
{
    if (m_contentItem == item) {
        return;
    }

    m_contentItem = item;
    item->setParentItem(this);
    m_contentItem->setX(m_leftPadding);
    m_contentItem->setY(m_topPadding);
    m_contentItem->setSize(QSizeF(width() - m_leftPadding - m_rightPadding,
                                  height() - m_topPadding - m_bottomPadding));

    emit contentItemChanged();
}

QQuickItem *AbstractDelegate::background() const
{
    return m_backgroundItem;
}

void AbstractDelegate::setBackground(QQuickItem *item)
{
    if (m_backgroundItem == item) {
        return;
    }

    m_backgroundItem = item;
    m_backgroundItem->setX(0);
    m_backgroundItem->setY(0);
    m_backgroundItem->setSize(size());

    emit backgroundChanged();
}

int AbstractDelegate::leftPadding() const
{
    return m_leftPadding;
}

void AbstractDelegate::setLeftPadding(int padding)
{
    if (m_leftPadding == padding) {
        return;
    }

    m_leftPadding = padding;
    syncChildItemsGeometry(size());
    emit leftPaddingChanged();
}


int AbstractDelegate::topPadding() const
{
    return m_topPadding;
}

void AbstractDelegate::setTopPadding(int padding)
{
    if (m_topPadding == padding) {
        return;
    }

    m_topPadding = padding;
    syncChildItemsGeometry(size());
    emit topPaddingChanged();
}


int AbstractDelegate::rightPadding() const
{
    return m_rightPadding;
}

void AbstractDelegate::setRightPadding(int padding)
{
    if (m_rightPadding == padding) {
        return;
    }

    m_rightPadding = padding;
    syncChildItemsGeometry(size());
    emit rightPaddingChanged();
}


int AbstractDelegate::bottomPadding() const
{
    return m_bottomPadding;
}

void AbstractDelegate::setBottomPadding(int padding)
{
    if (m_bottomPadding == padding) {
        return;
    }

    m_bottomPadding = padding;
    syncChildItemsGeometry(size());
    emit bottomPaddingChanged();
}


void AbstractDelegate::setSessionData(SessionDataMap *data)
{
    //possible to call only once, by the skillview upon instantiation
    Q_ASSERT(!m_data);
    m_data = data;
}

SessionDataMap *AbstractDelegate::sessionData() const
{
    return m_data;
}

void AbstractDelegate::setQmlUrl(const QUrl &url)
{
    //possible to call only once, by the skillview upon instantiation
    Q_ASSERT(m_qmlUrl.isEmpty());
    m_qmlUrl = url;
}

QUrl AbstractDelegate::qmlUrl() const
{
    return m_qmlUrl;
}

void AbstractDelegate::setSkillId(const QString &skillId)
{
    //possible to call only once, by the skillview upon instantiation
    Q_ASSERT(m_skillId.isEmpty());
    m_skillId = skillId;
}

QString AbstractDelegate::skillId() const
{
    return m_skillId;
}

#include "moc_abstractdelegate.cpp"
