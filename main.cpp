/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *  Copyright 2018 David Edmundson <davidedmundson@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <QGuiApplication>
#include <QQuickView>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlContext>
#include <QtQml>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QStringList arguments;
    for (int a = 0; a < argc; ++a) {
        arguments << QString::fromLocal8Bit(argv[a]);
    }
//FIXME: this should just go away on any platform
#ifndef Q_OS_ANDROID
    //qputenv("QT_QUICK_CONTROLS_STYLE", "Plasma");
#endif

    QCommandLineParser parser;

    auto widthOption = QCommandLineOption("width", "width", "width");
    auto heightOption = QCommandLineOption("height", "height", "height");
    auto hideTextInputOption = QCommandLineOption("hideTextInput");
    auto dpiOption = QCommandLineOption("dpi", "dpi", "dpi");
    parser.addOptions({widthOption, heightOption, hideTextInputOption, dpiOption});

    parser.process(arguments);

    qputenv("QT_WAYLAND_FORCE_DPI", parser.value(dpiOption).toLatin1());

    QGuiApplication app(argc, argv);

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    int width = parser.value(widthOption).toInt();
    int height = parser.value(heightOption).toInt();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("deviceWidth", width);
    engine.rootContext()->setContextProperty("deviceHeight", height);
    engine.rootContext()->setContextProperty("hideTextInput", parser.isSet(hideTextInputOption));

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
