/*
Provides a List of posts.
*/

import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    id: postList

    property var model: ListModel{}

    signal refreshPosts();

    function str_default() {
        return 'unknown';
    }

    Component {
        id: postListComponent

        ListElement {
            id: postListElement
            property string guid: str_default()
            property string created_at: '2020-01-14'
            property string type: str_default()
            property string post_title: 'This is a very long post title about very long adfsadfasdfa dfasd sadf asd afdasd fasdf asdfsa important things'
            property string post_body: 'blah\nblah\nblah'
            property string provider_display_name: str_default()
            property string is_public: str_default()
            property string is_nsfw: str_default()
            property string author_guid: str_default()
            property string author_diaspora_id: str_default()
            property string author_name: 'Author Name'
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
                contentItem: Post {}
                background: Rectangle {
                    width: parent.width
                    height: parent.height
                    opacity: 0.5
                    color: 'blue'
                }
            }
        }
    }

    function add_post(post, user) {
        var nd = postListComponent.createObject (
            postList.model,
            {
                guid: post.guid,
                created_at: post.created_at,
                post_title: post.title,
                post_body: post.body,
                author_name: post.author.name,
                author_guid: post.author.guid,
                author_avatar: ('avatar' in post.author) ? post.author.avatar : '',
            }
        );
        postList.model.append(nd);
    }

    Component.onCompleted: {
//Example provided by API documentation:
//https://diaspora.github.io/api-documentation/routes/posts.html
//        const json_example_post_text = '' +
//            '{' +
//              '"guid": "83d406e0b9b20133e40c406c8f31e210",' +
//              '"created_at": "2016-02-20T03:46:57.955Z",' +
//              '"post_type": "StatusMessage",' +
//              '"title": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a di.",' +
//              '"body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor.",' +
//              '"provider_display_name": "ExampleApp",' +
//              '"public": true,' +
//              '"nsfw": false,' +
//              '"author": {' +
//                '"guid": "f50ffc00b188013355e3705681972339",' +
//                '"diaspora_id": "alice@example.com",' +
//                '"name": "Alice Testing",' +
//                '"avatar": ""' +
//              '},' +
//              '"interaction_counters": {' +
//                '"comments": 14,' +
//                '"likes": 42,' +
//                '"reshares": 9' +
//              '}' +
//            '}';
//        var example_post = JSON.parse(json_example_post_text);
//        var i;

//        for (i = 0; i < 20; i++) {
//            postList.add_post(example_post);
//        }
    }
}
