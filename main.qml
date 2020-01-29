import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import "diaspora_api.js" as DiasporaAPI

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Diaspora Client Example")

    readonly property int m_Posts: 1
    readonly property int m_Settings: 2

    readonly property int m_Disconnected: 1
    readonly property int m_Connecting: 2
    readonly property int m_Connected: 3

    property int showing: m_Settings
    property int state: m_Disconnected

    Page {
        id: contentPage
        anchors.fill: parent

        header: ToolBar {
            id: contentPageHeader
            RowLayout {
                anchors.fill: parent

                Label {
                    id: contentPageHeaderLabel
                    text: if (showing == m_Posts) {
                        'Pod Name'
                    } else if (showing == m_Settings) {
                        'Settings'
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

        PostList {
            visible: (showing === m_Posts)
            anchors.fill: parent
        }

        SettingList {
            id: settingList

            visible: (showing === m_Settings)
            anchors.fill: parent

            Component.onCompleted: {
                add_setting('Server/Pod', 'test');
                add_setting('foo/bar', 'baz');
            }
        }

        Menu {
            id: displayMenu
            title: 'Display'
            x: parent.width - width

            MenuItem {
                text: 'Connect...'
                enabled: !(state === m_Disconnected)
                onTriggered: showing = m_Posts
            }

            MenuItem {
                text: 'Disconnect...'
                enabled: (state === m_Connected)
                onTriggered: showing = m_Posts
            }

            MenuSeparator { }

            MenuItem {
                text: 'Show Posts...'
                enabled: !(showing === m_Posts)
                onTriggered: showing = m_Posts
            }

            MenuItem {
                text: 'Settings...'
                enabled: !(showing === m_Settings)
                onTriggered: showing = m_Settings
            }
        }
    }

    Component.onCompleted: {
        var dapi = {}
        DiasporaAPI.V1.call(dapi);
        dapi.test();
    }
}
