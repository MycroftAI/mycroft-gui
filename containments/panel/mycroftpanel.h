/***************************************************************************
 *   Copyright (C) 2018 Marco Martin <mart@kde.org>                        *
 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef MYCROFTPANEL_H
#define MYCROFTPANEL_H


#include <Plasma/Containment>


class MycroftPanel : public Plasma::Containment
{
    Q_OBJECT

public:
    MycroftPanel( QObject *parent, const QVariantList &args );
    ~MycroftPanel();

public Q_SLOTS:
    void executeCommand(const QString &command);
    void requestShowingDesktop();

private:

};

#endif
