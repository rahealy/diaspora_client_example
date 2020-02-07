/*
 * DiasporaClientExample.qml
 *  Page displays either a list of settings or a list of posts.
 *  Provides a menu that allows user to select which list is visible
 *  and manage connection state with a diaspora pod.
 */

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import "diaspora_api.js" as DiasporaAPI

Page {
    id: contentPage

    property int showing;   //m_Showing corresponding to showing section.
    property var dAPI: ({}) //JavaScript DiasporaAPI object.

    Item { //Psudo-enumeration lists section that is being displayed.
        id: m_Showing
        readonly property int m_Posts: 1
        readonly property int m_Connect: 2
        readonly property int m_Settings: 3
    }

/*
 * Header contains a toolbar with text, an action button and a
 * menu button.
 */
    header: ToolBar {
        id: contentPageHeader

        RowLayout {
            anchors.fill: parent

            Label {
                id: contentPageHeaderLabel
                text: ''

                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true

                function set_text() {
                    if (postsSection.visible) {
                        contentPageHeaderLabel.text = 'Posts'
                    } else if (settingsSection.visible) {
                        contentPageHeaderLabel.text = 'Settings'
                    } else if (connectSection.visible) {
                        contentPageHeaderLabel.text = 'Connection Status'
                    } else {
                        contentPageHeaderLabel.text = 'Diaspora Client Example'
                    }

                    if (connectSection.connected) {
                        contentPageHeaderLabel.text += ' - Connected to ' +
                            settingsSection.get_setting('Server/Pod Address');
                    }
                }
            }

            ToolButton {
                id: actionButton

                hoverEnabled: true
                ToolTip.timeout: 5000
                ToolTip.visible: hovered || pressed
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval

                onClicked: {
                    console.log("actionButton.onClicked(): HERE!")
                }

                function set_contents() {
                    if (postsSection.visible) {
                        actionButton.enabled = true;
                        actionButton.icon.name = 'view-refresh';
                        actionButton.ToolTip.text = 'Refresh posts.';
                    } else if (connectSection.visible) {
                        if (connectSection.connected) {
                            actionButton.enabled = true;
                            actionButton.icon.name = 'window-close';
                            actionButton.ToolTip.text = 'Disconnect from pod.';
                        } else if (connectSection.connecting) {
                            actionButton.enabled = true;
                            actionButton.icon.name = 'process-stop'; //Cancel.
                            actionButton.ToolTip.text = 'Cancel connecting to pod.';
                        } else if (connectSection.disconnecting) {
                            actionButton.enabled = false;
                        } else {
                            actionButton.enabled = true;
                            actionButton.icon.name = 'edit-undo';
                            actionButton.ToolTip.text = 'Connect to pod.';
                        }
                    } else if (settingsSection.visible) {
                        actionButton.enabled = false;
                        actionButton.icon.name = 'window-close';
                        actionButton.ToolTip.text = '';
                    } else {
                        actionButton.enabled = false;
                        actionButton.icon.name = '';
                        actionButton.ToolTip.text = '';
                    }
                }
            }

            ToolButton {
                text: qsTr("⋮")
                onClicked: displayMenu.open()
            }
        }
    } //ToolBar{}

/*
 * Show a modal dialog box if there's a problem.
 */
    DialogBox {
        id: messageDialog
        width: parent.width
        height: parent.height / 2;
        anchors.verticalCenter: parent.verticalCenter
        z: 100
    }

/*
 * Connect section manages connection with a diaspora pod.
 */
    Connect {
        id: connectSection
        visible: (showing === m_Showing.m_Connect)
        anchors.fill: parent

        Connections {
            target: actionButton
            enabled: connectSection.visible

            onClicked: {
                if (connectSection.connected) {
                    connectSection.beginDisconnecting();
                } else if (connectSection.connecting) {
                    connectSection.cancelConnecting();
                } else if (!connectSection.disconnecting) {
                    connectSection.beginConnecting();
                }
            }
        }

        onConnectingChanged: actionButton.set_contents();
        onDisconnectingChanged: actionButton.set_contents();
        onConnectedChanged: actionButton.set_contents();

        onVisibleChanged: {
            actionButton.set_contents();
            contentPageHeaderLabel.set_text();
        }
    }

/*
 * Posts secton loads and displays a list of posts from the user's
 * main stream.
 */
    PostList {
        id: postsSection
        visible: (showing === m_Showing.m_Posts)
        anchors.fill: parent

        Connections {
            target: actionButton
            enabled: postsSection.visible

            onClicked: {
                if (!(connectSection.connected ||
                      connectSection.disconnecting))
                {
                    messageDialog.show('Client is not connected to a pod. To connect, select '+
                                       '\'Connection Management...\' from the menu and click ' +
                                       'the connect icon.');
                } else {
                    update_stream();
                }
            }

            function update_stream() {
                dAPI.api_get_main_stream (
                    function(obj) {
                        if ('api_error' in obj) {
                            messageDialog.show(obj.api_error);
                        } else if ('error' in obj) {
                            if ('error_description' in obj) {
                                messageDialog.show(obj.error_description);
                            } else {
                                messageDialog.show('There was an unspecified error while retrieving posts.');
                            }
                        } else {
                            console.log('get_main_stream(): ' + JSON.stringify(obj))
                            postsSection.model.clear();
                            var post;
                            for(post of obj) {
                                postsSection.add_post(post);
                            }
                        }
                    }
                );
            }
        }

        onVisibleChanged: {
            actionButton.set_contents();
            contentPageHeaderLabel.set_text();
        }
    }

/*
 * Settings section displays a list of settings to edit.
 */
    SettingList {
        id: settingsSection

        visible: (showing === m_Showing.m_Settings)
        anchors.fill: parent

        onVisibleChanged: {
            actionButton.set_contents();
            contentPageHeaderLabel.set_text();
        }

        Component.onCompleted: {
            add_setting (
                'Server/Pod Address',
                'http://0.0.0.0:3000',
                'Diaspora pod location of format [domain|ipaddr]:port'
            );
        }
    }

    Menu {
        id: displayMenu
        title: 'Display'
        x: parent.width - width

        MenuItem {
            text: 'Connection Management...'
            enabled: !connectSection.visible
            onTriggered: {
                contentPage.showing = m_Showing.m_Connect
            }
        }

        MenuItem {
            text: 'Posts...'
            enabled: !postsSection.visible
            onTriggered: {
                contentPage.showing = m_Showing.m_Posts
            }
        }

        MenuItem {
            text: 'Settings...'
            enabled: !settingsSection.visible
            onTriggered: {
                contentPage.showing = m_Showing.m_Settings
            }
        }
    }

    Component.onCompleted: {
        DiasporaAPI.V1.call(dAPI); //Initialize the api.
        showing = m_Showing.m_Settings;
        actionButton.set_contents('disconnected');
    }
}

