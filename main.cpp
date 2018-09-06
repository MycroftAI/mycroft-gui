#include <QGuiApplication>
#include <QQuickView>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlContext>
#include <QtQml>
#include <QFont>
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
    auto fontSizeOption = QCommandLineOption("fontSize", "fontSize", "fontSize");
    parser.addOptions({widthOption, heightOption, hideTextInputOption, fontSizeOption});

    parser.parse(QCoreApplication::arguments());
    parser.process(app);

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    int width = parser.value(widthOption).toInt();
    int height = parser.value(heightOption).toInt();
    int fontSize = parser.value(fontSizeOption).toInt();

    QFont font = app.font();

    //app font needs to be set before object creation
    if (fontSize > 0) {
        font.setPointSize(fontSize);
        app.setFont(font);
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("deviceWidth", width);
    engine.rootContext()->setContextProperty("deviceHeight", height);
    engine.rootContext()->setContextProperty("hideTextInput", parser.isSet(hideTextInputOption));

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().count() > 0) {
        QObject *obj = engine.rootObjects().first();
        if (fontSize > 0) {
            obj->setProperty("font", font);
        }
        if (width > 0) {
            obj->setProperty("width", width);
            obj->setProperty("minimumWidth", width);
            obj->setProperty("maximumWidth", width);
        }
        if (height > 0) {
            obj->setProperty("height", height);
            obj->setProperty("minimumHeight", height);
            obj->setProperty("maximumHeight", height);
        }
    }


    return app.exec();
}
