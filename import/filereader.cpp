/*
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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
       bool metaExist = file_exists_local(dirList[i] + QStringLiteral("/") + findFile);
       if(metaExist){
            containsMeta.append(dirList[i]);
       }
    }
    return containsMeta;
}
