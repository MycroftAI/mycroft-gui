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
