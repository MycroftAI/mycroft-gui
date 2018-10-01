/*
 * Copyright 2018 Kai Uwe Broulik <kde@broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#pragma once

#include <Plasma/Applet>

class ApplicationsModel;

class LauncherApplet : public Plasma::Applet
{
    Q_OBJECT

    Q_PROPERTY(ApplicationsModel *applicationsModel READ applicationsModel CONSTANT)

public:
    explicit LauncherApplet(QObject *parent, const QVariantList &data);
    ~LauncherApplet() override;

    void init() override;

    ApplicationsModel *applicationsModel() const;

private:
    ApplicationsModel *m_applicationsModel;

};
