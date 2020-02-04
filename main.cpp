#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "random.hpp"
#include "redirect_listener.hpp"
#include "sha256.hpp"

RandomAddOn RandomAddOnSingleton;
Sha256AddOn Sha256AddOnSingleton;

int main(int argc, char *argv[])
{
//    qmlRegisterType<QtRandom>("QtRandomAdapter", 1, 0, "QtRandom");

//    qmlRegisterUncreatableType<SHA256>(
//                "QtRandomAdapter", 1, 0,
//                "QtRandom",
//                "Can not create type in QML!"
//    );

    qmlRegisterSingletonInstance(
        "RandomAddOn", 1, 0,
        "Random", &RandomAddOnSingleton
    );

    qmlRegisterSingletonInstance(
        "Sha256AddOn", 1, 0,
        "Sha256", &Sha256AddOnSingleton
    );

    qmlRegisterType<RedirectListener>(
        "RedirectListener", 1, 0,
        "RedirectListener"
    );

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
