/*
 * redirectListener.hpp
 *  Listens to a TCP port for an incoming http request.
 */

#ifndef REDIRECTLISTENER_HPP
#define REDIRECTLISTENER_HPP

#include <iostream>
#include <QtQuick/QQuickItem>
#include <QTcpServer>
#include <QTcpSocket>
#include <QString>

const QByteArray HTML_DOCUMENT = ""
"HTTP/1.1 200 OK\r\n"
"Content-Type: text/html\r\n"
"Connection: Closed\r\n"
"\r\n"
"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\""
"    \"http://www.w3.org/TR/html4/strict.dtd\">"
"<html lang=\"en\">"
"  <head>"
"    <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">"
"    <title>title</title>"
"  </head>"
"  <body>"
"  <h2>Diaspora Client Example</h2>"
"  <p>Thank you for your interest in the Diaspora Client Example.</p>"
"  <p>Please close the browser and return to the application for the authentication result.</p>"
"  </body>"
"</html>";

class RedirectListener : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(quint32 port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool listening READ listening WRITE setListening NOTIFY listeningChanged)
    Q_PROPERTY(QString code READ code)
    Q_PROPERTY(QString state READ state)

public:
    RedirectListener(QQuickItem *parent = 0) : QQuickItem(parent),
                                               m_TcpSocket(0),
                                               m_address("127.0.0.1"),
                                               m_port(65534),
                                               m_listening(false) {
        m_TcpServer = new QTcpServer(this);
        connect(m_TcpServer, SIGNAL(newConnection()),
                this, SLOT(newConnection()));
    }

    QString address() const { return m_address; }
    quint16 port() const { return m_port; }
    bool listening() const { return m_listening; }
    QString code() const { return m_oauth_code; }
    QString state() const { return m_oauth_state; }

    void setAddress(const QString &addr) { m_address = addr; }
    void setPort(const quint32 &port){ m_port = port; }
    void setListening(const bool &listen) {
        if (m_listening && !listen) {
            this->m_TcpServer->close();
            m_listening = false;
        } else if (listen && !m_listening) {
            this->m_TcpServer->listen(QHostAddress(m_address), (qint16) m_port);
            m_listening = true;
        }
    }

signals:
    void addressChanged(const QString &p);
    void portChanged(const qint32 &p);
    void listeningChanged(const bool &p);
    void haveOAuth(const bool haveoauth);

public slots:
    void newConnection() {
        if (m_TcpSocket) { //Already connected deny further connections.
            QTcpSocket *s = m_TcpServer->nextPendingConnection();
            s->close();
        } else {
            m_TcpSocket = m_TcpServer->nextPendingConnection();
            connect(m_TcpSocket, SIGNAL(readyRead()),
                    this, SLOT(readyRead()));
            connect(m_TcpSocket, &QTcpSocket::disconnected,
                    m_TcpSocket, &QTcpSocket::deleteLater);
            setListening(false);
        }
    }

    void readyRead() { //Read up to 4096 bytes.
        const int MAXLEN = 4096;

        m_data.append (
            m_TcpSocket->readLine(MAXLEN)
        );
        std::cout << m_data.data() << std::endl;
        if (1 == m_Parse()) {
            emit haveOAuth(true);
            m_TcpSocket->write(HTML_DOCUMENT);
        } else {
            emit haveOAuth(false);
        }

        m_TcpSocket->close();
        m_TcpSocket = 0;
        setListening(false);
    }

private:
    int m_Parse() {
//Make sure it's a GET request.
        int getbreak = m_data.indexOf("GET");
        if (getbreak == -1) {
            return -1;
        } else {
            m_data = m_data.right(m_data.length() - (getbreak + 3));
        }

//Take the right side of the GET delimter.
        int delimbreak = m_data.indexOf("?");
        if (delimbreak == -1) {
            return -1;
        } else {
            m_data = m_data.right(m_data.length() - (delimbreak + 1));
        }

//Take the left side of the HTTP.
        int httpbreak = m_data.indexOf("HTTP/");
        if (httpbreak == -1) {
            return -1;
        } else {
            m_data.truncate(httpbreak);
        }

//list[1] contains the key/value pairs.
        QList<QByteArray> pairs = m_data.split('&');
        QList<QByteArray>::iterator iter = pairs.begin();

        for (; iter != pairs.end(); ++iter) {
            QList<QByteArray> keyval = iter->split('=');
            if(keyval.length() == 2) {
//keyval[0] contains the key.
//keyval[1] contains the val.
                keyval[0] = keyval[0].trimmed();
                keyval[1] = keyval[1].trimmed();
                if (keyval[0] == "code") {
                    m_oauth_code = keyval[1];
                } else if (keyval[0] == "state") {
                    m_oauth_state = keyval[1];
                }
                std::cout << "Key: " << keyval[0].data() << std::endl;
                std::cout << "Val: " << keyval[1].data() << std::endl;
            }
            std::cout << "Original: " << iter->data() << std::endl;
            std::cout << "m_oauth_code: " << m_oauth_code.data() << std::endl;
            std::cout << "m_oauth_state: " << m_oauth_state.data() << std::endl;
        }

        return ((m_oauth_code.length() > 0) &&
                (m_oauth_state.length() > 0)) ? 1 : 0;
    }

    QTcpServer *m_TcpServer;
    QTcpSocket *m_TcpSocket;
    QString m_address;
    quint32 m_port;
    bool m_listening;
    QByteArray m_data;
    QByteArray m_oauth_code;
    QByteArray m_oauth_state;
};

#endif // REDIRECTLISTENER_HPP
