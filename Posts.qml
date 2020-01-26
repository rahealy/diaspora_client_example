import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    anchors.fill: parent
    function nop() {}

    Page {
        id: page
        anchors.fill: parent

        header: ToolBar {
            RowLayout {
                anchors.fill: parent
                Label {
                    text: "Pod Name"
                    elide: Label.ElideRight
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }

                ToolButton {
                    text: qsTr("⋮")
                }
            }
        }

        PostList {
            anchors.fill: parent
        }
    }
}
