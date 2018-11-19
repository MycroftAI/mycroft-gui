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
