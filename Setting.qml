import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Row {
    id: row
    spacing: m_SPACING

    readonly property int m_SPACING: 5
    readonly property int m_MARGINS: 5

    Text {
        id: nameText
        text: name  //provided by settingListComponent in SettingList.qml
        elide: Label.ElideRight
    }

    Rectangle {
        border.color: 'grey'
        border.width: 1
        color: 'white'
        opacity: 1
        width: parent.width - nameText.contentWidth - historyButton.width - (m_SPACING * 3)
        height: valueText.contentHeight
        TextInput {
            id: valueText
            x: m_MARGINS
            width: parent.width - (m_MARGINS * 2)
            selectByMouse: true
            mouseSelectionMode: TextEdit.SelectCharacters
            wrapMode: Text.Wrap
            color: 'black'
            text: value //provided by settingListComponent in SettingList.qml
            onTextChanged: {
                model.value = text //Update the model in settingListComponent
            }
        }
    }

    ToolButton {
        id: historyButton
        height: nameText.height
        width: nameText.height
//        Layout.alignment: Qt.AlignTop | Qt.AlignRight
        text: qsTr("⋮")
    }
}
