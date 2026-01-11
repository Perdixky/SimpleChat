import QtQuick
import ModernChat

ListModel {
    id: root

    Component.onCompleted: {
        loadConversations()
    }

    function loadConversations() {
        clear()
        const conversations = MockData.getConversations()
        for (let i = 0; i < conversations.length; i++) {
            append(conversations[i])
        }
    }

    function getConversation(id) {
        for (let i = 0; i < count; i++) {
            if (get(i).conversationId === id) {
                return get(i)
            }
        }
        return null
    }

    function updateLastMessage(id, message, timestamp) {
        for (let i = 0; i < count; i++) {
            if (get(i).conversationId === id) {
                setProperty(i, "lastMessage", message)
                setProperty(i, "lastMessageTime", timestamp)
                if (!get(i).isPinned && i > 0) {
                    move(i, 0, 1)
                }
                break
            }
        }
    }

    function incrementUnread(id) {
        for (let i = 0; i < count; i++) {
            if (get(i).conversationId === id) {
                setProperty(i, "unreadCount", get(i).unreadCount + 1)
                break
            }
        }
    }

    function markAsRead(id) {
        for (let i = 0; i < count; i++) {
            if (get(i).conversationId === id) {
                setProperty(i, "unreadCount", 0)
                break
            }
        }
    }

    function setOnlineStatus(id, isOnline) {
        for (let i = 0; i < count; i++) {
            if (get(i).conversationId === id) {
                setProperty(i, "isOnline", isOnline)
                break
            }
        }
    }

    function filterByName(searchText) {
        clear()
        const conversations = MockData.getConversations()
        const search = searchText.toLowerCase()

        for (let i = 0; i < conversations.length; i++) {
            if (conversations[i].name.toLowerCase().includes(search)) {
                append(conversations[i])
            }
        }
    }
}
