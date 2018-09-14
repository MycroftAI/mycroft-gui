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

    qputenv("QT_QUICK_CONTROLS_STYLE", "Plasma");

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
