pragma ComponentBehavior: Bound
import QtQuick
import ModernChat
import QtQuick.Controls

ListView {
    id: root

    property string currentConversationId: ""
    property string searchText: ""

    signal conversationSelected(string id, var room)

    clip: true
    boundsBehavior: Flickable.StopAtBounds

    model: roomList

    delegate: ConversationDelegate {
        required property var room
        required property string displayName
        required property string lastMessage
        required property var lastMessageTime
        required property int unreadCount

        conversationId: room ? room.roomId : ""
        name: displayName
        avatar: ""  // TODO: 从 room 获取头像
        isOnline: connection.isOnline
        isSelected: root.currentConversationId !== "" && root.currentConversationId === conversationId

        onSelected: (id) => {
            root.currentConversationId = id
            root.conversationSelected(id, room)
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "y"
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    add: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1
                duration: 250
                easing.type: Easing.OutBack
            }
        }
    }

    remove: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 150
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.8
                duration: 150
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
    }

    Label {
        anchors.centerIn: parent
        visible: root.count === 0
        text: root.searchText !== "" ? qsTr("No conversations found") : qsTr("No conversations yet")
        color: ThemeManager.textMuted
        font.pixelSize: 14

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }
    }
}
