import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import RedirectListener 1.0

Rectangle {
    id: connectRectangle
    anchors.fill: parent

    property bool connection_canceled: false
    property bool connected: false
    property bool connecting: false
    property bool disconnecting: false

    signal beginConnecting();
    signal connectingToPod();
    signal diasporaNodeInfoFound(var obj);
    signal openIdServiceDiscovered(var obj);
    signal openIdClientRegistered(var obj);
    signal openIdClientAuthorized(var obj);
    signal accessTokenGranted(var obj);
    signal connectedToPod(var obj);
    signal cancelConnecting();
    signal beginDisconnecting();
    signal disconnectingFromPod();
    signal disconnectedFromPod();

    RedirectListener {
        id: redirectListener
        port: 65080
        address: '127.0.0.1'

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
            height: parent.height
            text: ''
            readOnly: true
            wrapMode: TextEdit.WordWrap
            selectByMouse: true
        }
    }

/*
 * Signals are in order of invocation.
 */
    onBeginConnecting: {
        console.log('onBeginConnecting');
        if (!(connected || connecting || disconnecting)) {
            var podAddress = settingsSection.get_setting('Server/Pod Address');
            var listenerURI = 'http://' +
                              redirectListener.address +
                              ':' +
                              redirectListener.port;
            connectingStatusText.text = dAPI.get_message() + '\n';
            connectingStatusText.text += 'Begin Connecting to ' + podAddress + '...\n';
            connection_canceled = false;
            connecting = true;
            dAPI.init(podAddress, listenerURI);
            dAPI.transition('next', connectingToPod);
        }
    }

    onConnectingToPod: {
        console.log('onConnectingToPod');
        connectingStatusText.text += 'Connecting...\n'
        dAPI.transition('next', diasporaNodeInfoFound);
    }

    onDiasporaNodeInfoFound: {
        console.log('onDiasporaNodeInfoFound');
        if (connection_canceled || !connecting) {
            console.log('onDiasporaNodeInfoFound: connection canceled.');
        } else if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n'
            cancelConnecting();
        } else {
            connectingStatusText.text += 'Diaspora node found. Discovering OpenId...\n'
            dAPI.transition('next', openIdServiceDiscovered);
        }
    }

    onOpenIdServiceDiscovered: {
        console.log('onOpenIdServiceDiscovered');
        if (connection_canceled || !connecting) {
            console.log('onOpenIdServiceDiscovered: connection canceled.');
        } else if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n'
            cancelConnecting();
        } else {
            connectingStatusText.text +=
                'OpenId service found. Registering client example...\n';
            dAPI.transition('next', openIdClientRegistered);
        }
    }

    onOpenIdClientRegistered: {
        console.log('onOpenIdClientRegistered');
        if (connection_canceled || !connecting) {
            console.log('onOpenIdClientRegistered: connection canceled.');
        } else if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n'
            cancelConnecting();
        } else {
            connectingStatusText.text += 'Client example registered. ' +
                                         'Getting user authorization...\n';
            redirectListener.listening = true;
            dAPI.transition('next', openIdClientAuthorized);
        }
    }

    onOpenIdClientAuthorized: {
        console.log('onOpenIdClientAuthorized');
        if (connection_canceled || !connecting) {
            console.log('onOpenIdClientAuthorized: connection canceled.');
        } else if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n';
            cancelConnecting();
        } else {
            connectingStatusText.text += 'User authorized client.' +
                                         ' Getting client access token...\n';
            dAPI.transition('next', accessTokenGranted);
        }
    }

    onAccessTokenGranted: {
        console.log('onAccessTokenGranted');
        if (connection_canceled || !connecting) {
            console.log('onAccessTokenGranted: connection canceled.');
        } else if ('api_error' in obj) {
            connectingStatusText.text += obj.api_error + '\n';
            cancelConnecting();
        } else {
            connectingStatusText.text += 'Client access token granted.\n';
            connected = true;
            dAPI.transition('next', connectedToPod);
        }
    }

    onConnectedToPod: {
        console.log('onConnectedToPod');
        if (connection_canceled || !connecting) {
            console.log('onConnectedToPod: connection canceled.');
        } else {
            connectingStatusText.text += 'Connected.\n';
        }
    }

    onCancelConnecting: { //Called when connecting and cancel button is pressed.
        console.log('onCancelConnecting');
        connectingStatusText.text += 'Connection canceled.\n';
        connection_canceled = true;
        disconnecting       = true;
        connecting          = false;
        redirectListener.listening = false;
        dAPI.transition('cancel', disconnectingFromPod);
    }

    onBeginDisconnecting: { //Called when connected and disconnect button is pressed.
        console.log('onBeginDisconnecting');
        connectingStatusText.text += 'Begin disconnecting from pod.\n';
        connection_canceled = false;
        disconnecting       = true;
        connecting          = false;
        redirectListener.listening = false;
        dAPI.transition('next', disconnectingFromPod);
    }

    onDisconnectingFromPod: {
        console.log('onDisconnectingFromPod');
        connectingStatusText.text += 'Disconnecting from pod...\n';
        dAPI.transition('next', disconnectedFromPod);
    }

    onDisconnectedFromPod: {
        console.log('onDisconnectedFromPod');
        connectingStatusText.text += 'Disconnected from pod.\n';
        disconnecting       = false;
        connected           = false;
    }
}
