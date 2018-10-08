/*
 *   Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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

#include "filereader.h"
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QDirIterator>

FileReader::FileReader(QObject *parent) 
    : QObject(parent)
{
}

QByteArray FileReader::read(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
        return QByteArray();

    return file.readAll();
}

bool FileReader::file_exists_local(const QString &filename) {
    return QFile(filename).exists();
}

QStringList FileReader::checkForMeta(const QString &rootDir, const QString &findFile){
    QStringList dirList;
    QStringList containsMeta;
    QDirIterator iter(rootDir);
    while(iter.hasNext()){
        dirList.append(iter.next());
    }
    int count = dirList.count();
    for(int i=0; i<count; i++){
       bool metaExist = file_exists_local(dirList[i] + "/" + findFile);
       if(metaExist){
            containsMeta.append(dirList[i]);
       }
    }
    return containsMeta;
}
