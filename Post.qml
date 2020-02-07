import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {
    id: postPage
    spacing: 2

    readonly property int m_SPACING: 5
    readonly property int m_MARGINS: 2
    property bool summary: true

    header: ToolBar {
        id: pageHeaderToolbar

        Row {
            id: toolBarRow
            anchors.fill: parent
            spacing: postPage.m_SPACING

            Rectangle { //Spacer for left side of page header.
                width:  1
                height: 1
                color: 'transparent'
            }

            Column {
                id: authorColumn

                Text {
                    id: authorNameLabel
                    text: author_name //provided by postListComponent in PostList.qml
                    elide: Label.ElideRight
                }

                Rectangle {
                    id: authorAvatarRectangle
                    width: authorNameLabel.contentWidth
                    height: 54
                    color: 'transparent'

                    Rectangle {
                        width: 52
                        height: width
                        clip: true
                        color: 'transparent'
                        border.color: 'white'
                        border.width: 2
                        anchors.centerIn: parent

                        Text {
                            text: 'No Image'
                            anchors.centerIn: parent
                            rotation: -45
                        }

                        Image {
                            id: authorAvatarImage
                            width: parent.width - (parent.border.width * 2)
                            height: parent.height - (parent.border.width * 2)
                            source: author_avatar //provided by postListComponent in PostList.qml
                            sourceSize.width: width
                            sourceSize.height: height
                            anchors.centerIn: parent
                        }
                    }
                }

                Rectangle { //Spacer for bottom of picture.
                    width:  authorNameLabel.contentWidth
                    height: postPage.m_SPACING
                    color: 'transparent'
                }
            }

            Column {
                id: titleColumn
                height: parent.height

                Label {
                    id: createdAtLabel
                    width: postPage.width -
                           authorColumn.width -
                           muteButton.width -
                           (postPage.m_SPACING * 3) - 1
                    elide: Label.ElideRight
                    font.bold: true
                    text: created_at //provided by postListComponent in PostList.qml
                }

                Text {
                    id: titleLabel
                    width: postPage.width -
                           authorColumn.width -
                           muteButton.width -
                           (postPage.m_SPACING * 3) - 1
                    height: titleColumn.height - createdAtLabel.height
                    elide: Label.ElideRight
                    wrapMode: Text.WordWrap
                    text: post_title //provided by postListComponent in PostList.qml
                }
            }

            ToolButton {
                id: muteButton
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                text: qsTr("X")
            }
        }

        Component.onCompleted: {}
    }

    Column {
        id: bodyTextColumn
        anchors.fill: parent
        anchors.margins: postPage.m_MARGINS

        Text {
            id: postBodyText
            width: parent.width
            //height: 20
            elide: Label.ElideRight
            wrapMode: Text.WordWrap
            text: post_body //provided by postListComponent in PostList.qml
        }

        Rectangle { //Spacer for bottom of text.
            width:  parent.width
            height: postPage.m_SPACING
            color: 'transparent'
        }
    }
}
