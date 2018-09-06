#include <QGuiApplication>
#include <QQuickView>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlContext>
#include <QtQml>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    qputenv("QT_QUICK_CONTROLS_STYLE", "Plasma");

    QGuiApplication app(argc, argv);
    QCommandLineParser parser;

    auto widthOption = QCommandLineOption("width", "width", "width");
    auto heightOption = QCommandLineOption("height", "height", "height");
    auto hideTextInputOption = QCommandLineOption("hideTextInput");
    parser.addOptions({widthOption, heightOption, hideTextInputOption});
    parser.parse(QCoreApplication::arguments());
    parser.process(app);

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    int width = parser.value(widthOption).toInt();
    int height = parser.value(heightOption).toInt();

    view.engine()->rootContext()->setContextProperty("deviceWidth", width);
    view.engine()->rootContext()->setContextProperty("deviceHeight", height);
    view.engine()->rootContext()->setContextProperty("hideTextInput", parser.isSet(hideTextInputOption));

    if (width && height) {
        view.setMinimumWidth(width);
        view.setMinimumHeight(height);
    }

    view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    view.show();

    return app.exec();
}
