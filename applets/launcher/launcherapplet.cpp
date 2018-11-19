/*
 * Copyright 2018 Kai Uwe Broulik <kde@broulik.de>
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
