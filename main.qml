import QtQuick 2.12
import QtQuick.Controls 2.5

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Scroll")

    Posts {
    }
}
/*
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: Rectangle {
        }
    }

Page {
            id: page
            width: 200
            height: 200
            anchors.fill: parent

            header: ToolBar {
                Column {
                    id: column
                    anchors.fill: parent

                    ToolButton {
                        text: qsTr("⋮")
                        onClicked: menu.open()
                    }
                }


                RowLayout {
                anchors.fill: parent
                ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
                }
                Label {
                text: "Title"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                }
            }

            ScrollView {
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: -68
                anchors.fill: parent

                ListView {
                    width: parent.width
                    model: 20
                    delegate: ItemDelegate {
                        text: "Item " + (index + 1)
                        width: parent.width
                    }
                }
            }
        }
*/
