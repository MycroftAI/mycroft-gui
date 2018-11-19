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

#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>
#include <QStringList>
#include <QDir>
#include <QTextStream>
#include <QDataStream>

class FileReader : public QObject
{
    Q_OBJECT

public:
    explicit FileReader(QObject *parent = Q_NULLPTR);
    
public Q_SLOTS:
    QByteArray read(const QString &filename);
    bool file_exists_local(const QString &filename);
    QStringList checkForMeta(const QString &rootDir, const QString &findFile);
};

#endif // FILEREADER_H
