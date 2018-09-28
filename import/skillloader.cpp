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

#include "skillloader.h"

#include <QStandardPaths>
#include <QFileInfo>
#include <QDebug>

#include <config-mycroft.h>

SkillLoader::SkillLoader(QObject *parent):
    QObject(parent)
{

}

SkillLoader::~SkillLoader()
{
}

QString SkillLoader::uiForMetadataType(const QString &metaDataType) const
{
    if (metaDataType.isEmpty()) {
        return QString();
    }
    const QString filePath = MYCROFT_SKILLS_UI_DIR + QLatin1String("/") + metaDataType + "/Main.qml";
    qDebug() << "looking for" << filePath;
    if (QFileInfo::exists(filePath)) {
        return  QUrl::fromLocalFile(filePath).toString();
    }
    qWarning() << "could not find delegate for " << metaDataType;
    return QString();
}
