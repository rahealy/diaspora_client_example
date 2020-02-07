/**********************************************************************
 * Provides an interface to QRandomGenerator for  QML + JavaScript.
 * QRandomGeneratory is a superior source of cryptographically-safe
 * random values.
 *********************************************************************/

#ifndef RANDOM_HPP
#define RANDOM_HPP

#include <QtQml>
#include <QObject>
#include <QQmlEngine>
#include <QRandomGenerator>

class RandomAddOn : public QObject
{
    Q_OBJECT

public:
    RandomAddOn(QObject *parent = 0) : QObject(parent) {}
    ~RandomAddOn() {}
    Q_INVOKABLE static quint32 randomNumber();
    Q_INVOKABLE static float randomFloat();
    Q_INVOKABLE static QByteArray randomHexString();
    void static registerSingleton(QQmlEngine *qmlEngine);
};

#endif // RANDOM_HPP
