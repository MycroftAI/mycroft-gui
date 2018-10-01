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

#include "launcherapplet.h"

#include <QTimer>
#include <QQmlEngine> // for qmlRegisterType

#include <KSycoca>

#include "applicationsmodel.h"

LauncherApplet::LauncherApplet(QObject *parent, const QVariantList &data)
    : Plasma::Applet(parent, data)
    , m_applicationsModel(new ApplicationsModel(this))
{
    qmlRegisterType<ApplicationsModel>();
}

LauncherApplet::~LauncherApplet() = default;

void LauncherApplet::init()
{
    m_applicationsModel->reload();

    connect(KSycoca::self(), QOverload<const QStringList &>::of(&KSycoca::databaseChanged), this, [this](const QStringList &changes) {
        if (changes.contains(QLatin1String("services")) || changes.contains(QLatin1String("apps")) || changes.contains(QLatin1String("xdgdata-apps"))) {
            QTimer::singleShot(100, m_applicationsModel, &ApplicationsModel::reload);
        }
    });
}

ApplicationsModel *LauncherApplet::applicationsModel() const
{
    return m_applicationsModel;
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(launcher, LauncherApplet, "metadata.json")

#include "launcherapplet.moc"
