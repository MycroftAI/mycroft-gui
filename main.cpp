#include <QGuiApplication>
#include <QQuickView>
#include <QtQml>
#include "mycroft.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<Mycroft>("Mycroft", 1, 0, "Mycroft");
    QQuickView view;
    view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    view.show();

    return app.exec();
}
