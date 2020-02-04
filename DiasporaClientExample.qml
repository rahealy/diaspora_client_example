/*
 * DiasporaClientExample.qml
 *  Page displays either a list of settings or a list of posts.
 *  Provides a menu that allows user to select which list is visible
 *  and manage connection state with a diaspora pod.
 */

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Page {
    id: contentPage

    property var dapi: ({}) //JavaScript diaspora api.

    Item { //Psudo-enumeration lists page that is being displayed.
        id: m_Showing
        readonly property int m_Posts: 1
        readonly property int m_Connect: 2
        readonly property int m_Settings: 3
    }

    Item { //Psudo-enumeration lists connection states.
        id: m_State
        readonly property int m_Connected: 1
        readonly property int m_Connecting: 2
        readonly property int m_Disconnected: 3
        readonly property int m_Disconnecting: 4
    }

    property int showing: m_Showing.m_Settings
    property int state: m_State.m_Disconnected

    header: ToolBar {
        id: contentPageHeader
        RowLayout {
            anchors.fill: parent

            Label {
                id: contentPageHeaderLabel
                text: if (showing === m_Showing.m_Posts) {
                    'Pod Name'
                } else if (showing === m_Showing.m_Settings) {
                    'Settings'
                } else if (showing === m_Showing.m_Connect) {
                    'Connection Status'
                } else {
                    'Diaspora Client Example'
                }

                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                text: qsTr("⋮")
                onClicked: displayMenu.open()
            }
        }
    }

    Connect {
        id: connectItem
        visible: (showing === m_Showing.m_Connect)
        anchors.fill: parent
        state: parent.state
    }

    PostList {
        visible: (showing === m_Showing.m_Posts)
        anchors.fill: parent
    }

    SettingList {
        id: settingList

        visible: (showing === m_Showing.m_Settings)
        anchors.fill: parent

        Component.onCompleted: {
            add_setting(
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
            text: 'Connect...'
            enabled: state !== m_State.m_Disconnected
            onTriggered: {
                showing = m_Showing.m_Connect;
                connectItem.beginConnecting('');
            }
        }

        MenuItem {
            text: 'Disconnect...'
            enabled: (state === m_State.m_Connected)
            onTriggered: showing = m_Showing.m_Disconnecting
        }

        MenuSeparator { }

        MenuItem {
            text: 'Show Posts...'
            enabled: !(showing === m_Showing.m_Posts)
            onTriggered: showing = m_Showing.m_Posts
        }

        MenuItem {
            text: 'Settings...'
            enabled: !(showing === m_Showing.m_Settings)
            onTriggered: showing = m_Showing.m_Settings
        }
    }
}

