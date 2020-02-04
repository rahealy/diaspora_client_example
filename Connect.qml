import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import RedirectListener 1.0
import RandomAddOn 1.0
import Sha256AddOn 1.0
import "diaspora_api.js" as DiasporaAPI

Rectangle {
    id: connectRectangle
    anchors.fill: parent

    property var dAPI: ({}) //JavaScript DiasporaAPI object.

    signal beginConnecting(var obj);
    signal diasporaNodeInfoFound(var obj);
    signal openIdServiceDiscovered(var obj);
    signal openIdClientRegistered(var obj);
    signal openIdClientAuthorized(var obj);
    signal connectedToPod(var obj);
    signal connectingError(var obj);

    RedirectListener {
        id: redirectListener
        port: 65080

        onHaveOAuth: {
            console.log("RedirectListener.onHaveOAuth(): Result = " + haveoauth);
            if (haveoauth) {
                openIdClientAuthorized (
                    dAPI.client_authorization_response (
                        redirectListener.code,
                        redirectListener.state
                    )
                );
            } else {
                openIdClientAuthorized (
                    {
                        api_error: 'User denied client example access to diaspora' +
                                   'account or took too long to respond.'
                    }
                );
            }
        }
    }

    Column {
        anchors.fill: parent

        TextEdit {
            id: connectingStatusText
            width: parent.width
            height: parent.height - cancelButton.height
            text: ''
            readOnly: true
            wrapMode: TextEdit.WordWrap
            selectByMouse: true
        }

//        TextArea {
//            id: logText
//            width: parent.width
//            height: (parent.height - actionButton.height) / 2
//            text: ''
//        }

        Button {
            id: cancelButton
            visible: true
            width: parent.width
            text: 'Cancel'
            onClicked: {
            }
        }
    }

    Component.onCompleted: {
        DiasporaAPI.V1.call(dAPI); //Initialize the api.
    }

/*
 * Signals are in order of invocation.
 */
    onBeginConnecting: {
        console.log('onBeginConnecting');
        var podAddress = settingList.get_setting('Server/Pod Address');
        connectingStatusText.text = 'Connecting to ' + podAddress + '...\n';
        dAPI.init(podAddress);
        dAPI.transition('next', diasporaNodeInfoFound);
    }

    onDiasporaNodeInfoFound: {
        console.log('onDiasporaNodeInfoFound');
        if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n'
        } else {
            connectingStatusText.text += 'Diaspora node found. Discovering OpenId...\n'
            dAPI.transition('next', openIdServiceDiscovered);
        }
    }

    onOpenIdServiceDiscovered: {
        console.log('onOpenIdServiceDiscovered');
        if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n'
        } else {
            connectingStatusText.text +=
                'OpenId service found. Registering client example...\n';
            dAPI.transition('next', openIdClientRegistered);
        }
    }

    onOpenIdClientRegistered: {
        console.log('onOpenIdClientRegistered');
        if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n'
        } else {
            connectingStatusText.text += 'Client example registered. ' +
                                         'Getting user authorization...\n';
            redirectListener.listening = true;
            dAPI.transition('next', openIdClientAuthorized);
        }
    }

    onOpenIdClientAuthorized: {
        console.log('onOpenIdClientAuthorized');
        if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n';
        } else {
            connectingStatusText.text += 'User authorized client.' +
                                         ' Getting client access token...\n';
            dAPI.transition('next', connectedToPod);
        }
    }

    onConnectedToPod: {
        console.log('onConnectedToPod');
        if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n';
        } else {
            connectingStatusText.text += 'Client access token granted. Connected.\n';
            dAPI.transition('next', connectedToPod);
        }
    }

    onConnectingError: {
        console.log('onConnectingError');
    }
}
