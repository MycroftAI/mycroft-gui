/*
 * Copyright 2020 by Aditya Mehra <aix.m@outlook.com>
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

#include <QtGui>
#include <QtQml>
#include "keyfilter.h"

KeyFilter::KeyFilter(QObject *parent) 
    : QObject(parent)
{
}

bool KeyFilter::eventFilter(QObject *watched, QEvent *event)
{
    QKeyEvent *key = static_cast<QKeyEvent *>(event);
    if (event->type() == QEvent::KeyPress && key->key() == Qt::Key_Back) {
            globalBackReceived();
            return true;
    }
    return false;
}
