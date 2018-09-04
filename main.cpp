#include <QGuiApplication>
#include <QQuickView>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QtQml>
#include "mycroft.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    qputenv("QT_QUICK_CONTROLS_THEME", "plasma");
    qputenv("QT_WAYLAND_FORCE_DPI", "200");

    QGuiApplication app(argc, argv);
    QCommandLineParser parser;

    auto widthOption = QCommandLineOption("width", "width", "width");
    auto heightOption = QCommandLineOption("height", "height", "height");
    parser.addOptions({widthOption, heightOption});
    parser.parse(QCoreApplication::arguments());
    parser.process(app);

    qmlRegisterType<Mycroft>("Mycroft", 1, 0, "Mycroft");

    QQuickView view;
    int width = parser.value(widthOption).toInt();
    int height = parser.value(heightOption).toInt();

    view.setResizeMode(QQuickView::SizeRootObjectToView);
    if (width > 0) {
        view.setWidth(width);
        view.setMinimumWidth(width);
        view.setMaximumWidth(width);
    }
    if (height > 0) {
        view.setWidth(height);
        view.setMinimumWidth(height);
        view.setMaximumWidth(height);
    }

    view.setSource(QUrl(QStringLiteral("main.qml")));
    view.show();

    return app.exec();
}
