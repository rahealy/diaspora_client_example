/**********************************************************************
 * Provides an interface to QCryptographicHash for  QML + JavaScript.
 *********************************************************************/

#ifndef SHA256_HPP
#define SHA256_HPP
#include <QtQuick/QQuickItem>
#include <QCryptographicHash>

class Sha256AddOn : public QQuickItem
{
    Q_OBJECT

public:
    Sha256AddOn(QQuickItem *parent = 0) : QQuickItem(parent) {}
    ~Sha256AddOn() {}

    Q_INVOKABLE static QByteArray hash(const QByteArray &data) {
        return QCryptographicHash::hash(data, QCryptographicHash::Sha256);
    }
};

#endif // SHA256_HPP
