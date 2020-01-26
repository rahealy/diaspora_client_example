import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    id: postList

    property var model: ListModel{}

    function str_default() {
        return 'unknown';
    }

    Component {
        id: postListComponent

        ListElement {
            id: postListElement

            property string guid: str_default()
            property string created_at: '2020-01-14' // str_default()
            property string type: str_default()
            property string title: 'This is a very long post title about very long adfsadfasdfa dfasd sadf asd afdasd fasdf asdfsa mportant things' //str_default()
            property string body: 'blah\nblah\nblah' //str_default()
            property string provider_display_name: str_default()
            property string is_public: str_default()
            property string is_nsfw: str_default()
            property string author_guid: str_default()
            property string author_diaspora_id: str_default()
            property string author_name: 'Author Name' //str_default()
            property string author_avatar: str_default()
            property string interaction_counters_comments: str_default()
            property string interaction_counters_likes: str_default()
            property string interaction_counters_reshares: str_default()
        }
    }

    ScrollView {
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        anchors.fill: parent

        ListView {
            id: listView

            width: parent.width
            model: postList.model
            anchors.fill: parent

            delegate: ItemDelegate {
                width: parent.width

                contentItem: Page {
                    id: pageItem
                    spacing: 2
                    header: ToolBar {
                        id: pageHeaderToolbar

                        Row {
                            id: toolBarRow
                            anchors.fill: parent
                            spacing: 5

                            Rectangle { //Spacer for left side.
                                width:  1
                                height: 1
                                color: 'transparent'
                            }

                            Column {
                                id: authorColumn

                                Label {
                                    id: authorNameLabel
                                    text: author_name
                                    elide: Label.ElideRight
                                    horizontalAlignment: Qt.AlignLeft
                                    verticalAlignment: Qt.AlignTop
                                    Layout.margins: 0
                                }

                                Rectangle {
                                    id: authorAvatarRectangle
                                    width: authorNameLabel.contentWidth
                                    height: 52
                                    color: 'transparent'
                                    border.color: 'white'
                                    border.width: 2
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.bottomMargin: 5

                                    Text {
                                        text: 'No Image'
                                        anchors.centerIn: parent
                                    }

                                    Image {
                                        id: authorAvatarImage
                                        width: 50
                                        height: 50
                                        anchors.centerIn: parent
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                    }
                                }

                                Rectangle { //Spacer for bottom of picture.
                                    width:  authorNameLabel.contentWidth
                                    height: toolBarRow.spacing
                                    color: 'transparent'
                                }
                            }

                            Column {
                                id: titleColumn
                                height: parent.height

                                Label {
                                    id: createdAtLabel
                                    width: pageItem.width -
                                           authorColumn.width -
                                           muteButton.width -
                                           (toolBarRow.spacing * 3) - 2
                                    elide: Label.ElideRight
                                    font.bold: true
                                    text: created_at
                                }

                                Text {
                                    id: titleLabel
                                    width: pageItem.width -
                                           authorColumn.width -
                                           muteButton.width -
                                           (toolBarRow.spacing * 3)
                                    height: titleColumn.height - createdAtLabel.height
                                    elide: Label.ElideRight
                                    wrapMode: Text.WordWrap
                                    text: title
                                }
                            }

                            ToolButton {
                                id: muteButton
                                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                                text: qsTr("X")
                            }
                        }
                    }

                    Label {
                        id: bodyText
                        text: body
                        wrapMode: Text.WordWrap
                        anchors.fill: parent
                    }
                }

                background: Rectangle {
                    width: parent.width
                    height: parent.height
                    opacity: 0.5
                    color: 'blue'
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("PostList.Component.onCompleted: Begin.")
        var i;
        for (i = 0; i < 20; i++) {
            var nd = postListComponent.createObject(postList.model);
            nd.guid = '' + i;
            postList.model.append(nd);
            console.log("PostList.Component.onCompleted: Added component to list model.")
        }
        console.log("PostList.Component.onCompleted: End.")
    }

}
/*
                            ColumnLayout {
                                id: columnLayoutAuthor
                                spacing: 0
                                Layout.margins: 0

                                Label {
                                    Layout.margins: 0
                                    text: author_name
                                    elide: Label.ElideRight
                                }

                                Rectangle {
                                    Layout.margins: 0
                                    height: 40
                                    width: 40
                                    color: 'green'
                                    Layout.alignment: Qt.AlignCenter
                                }
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.alignment: Qt.AlignTop
                                Layout.fillWidth: true
                                Label {
                                    Layout.margins: 0
                                    elide: Label.ElideRight
                                    text: created_at
                                }

                                Label {
                                    wrapMode: Text.WordWrap
                                    elide: Label.ElideRight
                                    text: title
                                }
                            }
*/
/*
        highlight: Rectangle {
            color: "transparent"
            Triangle {
                width: 6
                height: 6
                strokeColor: listViewHighlightStrokeColor
                fillColor: listViewHighlightFillColor
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        model: DelegateModel {
            id: delegateModel

            model: graphNodeList.model
            delegate: graphNodeListDelegate

            DragAndDropListViewDelegate {
                id: graphNodeListDelegate

                width: graphNodeListView.width
                height: graphNodeListContent.height

                listview: graphNodeListView
                dragparent: graphNodeList.dragparent
                content: graphNodeListContent
                dragtarget: graphNodeListContent
                listindex: index

                Rectangle {
                    id: graphNodeListContent
                    width: graphNodeListView.width
                    height: textColumn.height
                    color: ndcolor

                    Drag.keys: ['GraphNodeListItem']

                    Column {
                        id: textColumn
                        anchors.fill: parent

                        width: parent.width
                        height: nameText.paintedHeight + descText.paintedHeight

                        Text {
                            id: nameText
                            text: name
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            id: descText
                            text: desc
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Rectangle {
                        id: nodeListContentDragIndicatorRect
                        height: parent.height
                        width: parent.width
                        radius: parent.radius
                        color: "white"
                        opacity: parent.Drag.active ? 0.40 : 0.0
                    }
                }

                Component.onCompleted: {
//Add this item's key to the list of keys that the drop area accepts.
                    getDropArea().keys.push('GraphNodeListItem');
                }
            }
*/

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
