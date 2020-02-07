#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "RandomAddOn.hpp"
#include "RedirectListener.hpp"

int main(int argc, char *argv[])
{
//    qmlRegisterSingletonInstance(
//        "RandomAddOn", 1, 0,
//        "Random", &RandomAddOnSingleton
//    );

    qmlRegisterType<RandomAddOn>(
        "RandomAddOn", 1, 0,
        "Random"
    );

    qmlRegisterType<RedirectListener>(
        "RedirectListener", 1, 0,
        "RedirectListener"
    );

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    RandomAddOn::registerSingleton(&engine);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
