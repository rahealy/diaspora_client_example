/**********************************************************************
 * Provides an interface to QRandomGenerator for  QML + JavaScript.
 * QRandomGeneratory is a superior source of cryptographically-safe
 * random values.
 *********************************************************************/

#ifndef RANDOM_HPP
#define RANDOM_HPP
#include <QtQuick/QQuickItem>
#include <QRandomGenerator>

class RandomAddOn : public QQuickItem
{
    Q_OBJECT

public:
    RandomAddOn(QQuickItem *parent = 0) : QQuickItem(parent) {}
    ~RandomAddOn() {}

    Q_INVOKABLE static quint32 randomNumber() {
        return QRandomGenerator::global()->generate();
    }

    Q_INVOKABLE static float randomFloat() {
        return (
            (float) QRandomGenerator::global()->generate() /
            (float) std::numeric_limits<quint32>::max()
        );
    }

    Q_INVOKABLE static QByteArray randomHexString() {
        QByteArray ba;
        ba.setNum(QRandomGenerator::global()->generate(), 16);
        return ba;
    }
signals:
private:
};

#endif // RANDOM_HPP
