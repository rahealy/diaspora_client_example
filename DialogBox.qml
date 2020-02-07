import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Rectangle {
    id: dialogBox

    visible: false
    border.width: 1
    border.color: 'black'
    color: 'lightblue'

    Column {
        width: parent.width - (parent.border.width * 2);
        height: parent.height - (parent.border.width * 2);

        Row {
            height: parent.height - dialogBoxButton.height

            Button {
                id: dialogBoxIcon
//                height: parent.height
                icon.name: 'dialog-warning'
                background: Rectangle {
                    color: 'transparent'
                }
            }
            Rectangle {
                id: textRect
                width: dialogBox.width - dialogBoxIcon.width - 2
                height: dialogBox.height - dialogBoxButton.height
                color: 'transparent'
                clip: true
                TextEdit {
                    id: dialogBoxText
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    text: 'Click OK to continue...'
//                        width: parent.width
                    readOnly: true
                    wrapMode: TextEdit.WordWrap
                    selectByMouse: true
                }
            }
        }

        Button {
            id: dialogBoxButton
            x: dialogBox.border.width
            width: parent.width
            text: 'OK'
            onClicked: {
                dialogBox.visible = false;
            }
        }
    }

    function show(msg) {
        dialogBoxText.text = msg;
        dialogBox.visible = true;
    }
}
