/**********************************************************************
 * Provides an interface to QRandomGenerator for  QML + JavaScript.
 * QRandomGeneratory is a superior source of cryptographically-safe
 * random values.
 *********************************************************************/

#include <QtQml>
#include <QObject>
#include <QQmlEngine>
#include <QRandomGenerator>
#include "RandomAddOn.hpp"

static RandomAddOn RandomAddOnSingleton;

Q_INVOKABLE quint32 RandomAddOn::randomNumber() {
    return QRandomGenerator::global()->generate();
}

Q_INVOKABLE float RandomAddOn::randomFloat() {
    return (
        (float) QRandomGenerator::global()->generate() /
        (float) std::numeric_limits<quint32>::max()
    );
}

Q_INVOKABLE QByteArray RandomAddOn::randomHexString() {
    QByteArray ba;
    ba.setNum(QRandomGenerator::global()->generate(), 16);
    return ba;
}

void RandomAddOn::registerSingleton(QQmlEngine *qmlEngine) {
    QQmlContext *rootContext = qmlEngine->rootContext();
    rootContext->setContextProperty("Random", &RandomAddOnSingleton);
}
