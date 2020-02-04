import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtWebSockets 1.14
import "diaspora_api.js" as DiasporaAPI


ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Diaspora Client Example")

    property var dapi: ({});

    DiasporaClientExample {
        anchors.fill: parent
    }

    Component.onCompleted: {
//        redirectListener.listening = true;
//        DiasporaAPI.V1.call(applicationWindow.dapi);
//        dapi.set_pod('http://192.168.56.101:3000');
    }
}
