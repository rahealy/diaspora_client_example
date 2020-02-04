import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

//.well-known/openid-configuration

Item {
    id: settingList

    property var model: ListModel{}

    function str_default() {
        return 'unknown';
    }

    Component {
        id: settingListComponent

        ListElement {
            id: settingListElement
            property string name: str_default()
            property string value: str_default()
            property string tooltip: str_default()
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
            spacing: 0
            width: parent.width
            model: settingList.model
            anchors.fill: parent

            delegate: ItemDelegate {
                width: parent.width
                contentItem: Setting {
                    anchors.centerIn: parent
                }
                background: Rectangle {
                    border.width: 2
                    border.color: 'white'
                    anchors.fill: parent
                    opacity: 0.5
                    color: 'blue'
                }
            }
        }
    }

    function get_setting(name) {
        var i;
        for(i = 0; i < model.count; ++i) {
            var item = model.get(i);
            if (item.name === name) {
                return item.value;
            }
        }
        return undefined;
    }

    function add_setting(name, value, tooltip) {
        var nd = settingListComponent.createObject (
            settingList.model, {name: name,
                                value: value,
                                tooltip: tooltip}
        );
        settingList.model.append(nd);
    }

//    Component.onCompleted: {
//        add_setting('Server/Pod', 'test');
//        add_setting('foo/bar', 'baz');
////        var i;
////        for (i = 0; i < 20; i++) {
////            postList.add_post(example_post);
////        }
//    }
}

