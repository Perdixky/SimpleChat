pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var currentUser: ({
        id: "me",
        name: "Alex Chen",
        avatar: ""
    })

    readonly property var conversations: [
        {
            conversationId: "conv1",
            name: "Sarah Miller",
            avatar: "",
            lastMessage: "Sounds great! See you tomorrow!",
            lastMessageTime: new Date(2025, 0, 2, 14, 30),
            unreadCount: 2,
            isOnline: true,
            isPinned: true,
            isMuted: false
        },
        {
            conversationId: "conv2",
            name: "Dev Team",
            avatar: "",
            lastMessage: "Mike: The build is passing now",
            lastMessageTime: new Date(2025, 0, 2, 13, 15),
            unreadCount: 5,
            isOnline: false,
            isPinned: false,
            isMuted: false
        },
        {
            conversationId: "conv3",
            name: "John Davis",
            avatar: "",
            lastMessage: "Got it, thanks!",
            lastMessageTime: new Date(2025, 0, 2, 10, 0),
            unreadCount: 0,
            isOnline: true,
            isPinned: false,
            isMuted: false
        },
        {
            conversationId: "conv4",
            name: "Emma Wilson",
            avatar: "",
            lastMessage: "Are you free this weekend?",
            lastMessageTime: new Date(2025, 0, 1, 18, 45),
            unreadCount: 0,
            isOnline: false,
            isPinned: false,
            isMuted: true
        },
        {
            conversationId: "conv5",
            name: "Product Updates",
            avatar: "",
            lastMessage: "New feature released!",
            lastMessageTime: new Date(2025, 0, 1, 9, 0),
            unreadCount: 0,
            isOnline: false,
            isPinned: false,
            isMuted: true
        }
    ]

    readonly property var messages: ({
        "conv1": [
            {
                messageId: "msg1",
                content: "Hey! How's the project going?",
                timestamp: new Date(2025, 0, 2, 14, 0),
                senderId: "user1",
                isSent: false,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg2",
                content: "It's going well! Just finished the UI components.",
                timestamp: new Date(2025, 0, 2, 14, 5),
                senderId: "me",
                isSent: true,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg3",
                content: "That's awesome! Can you show me a demo?",
                timestamp: new Date(2025, 0, 2, 14, 10),
                senderId: "user1",
                isSent: false,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg4",
                content: "Sure! I'm using Qt 6 and QML. The animations are really smooth!",
                timestamp: new Date(2025, 0, 2, 14, 15),
                senderId: "me",
                isSent: true,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg5",
                content: "I'd love to see it. Can we meet tomorrow?",
                timestamp: new Date(2025, 0, 2, 14, 25),
                senderId: "user1",
                isSent: false,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg6",
                content: "Sounds great! See you tomorrow!",
                timestamp: new Date(2025, 0, 2, 14, 30),
                senderId: "user1",
                isSent: false,
                status: 3,
                type: "text"
            }
        ],
        "conv2": [
            {
                messageId: "msg1",
                content: "Team, we need to fix the build issue ASAP",
                timestamp: new Date(2025, 0, 2, 12, 0),
                senderId: "user2",
                isSent: false,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg2",
                content: "I'm looking into it now",
                timestamp: new Date(2025, 0, 2, 12, 30),
                senderId: "me",
                isSent: true,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg3",
                content: "Found the issue - it was a missing dependency",
                timestamp: new Date(2025, 0, 2, 13, 0),
                senderId: "me",
                isSent: true,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg4",
                content: "Great work! Can you push the fix?",
                timestamp: new Date(2025, 0, 2, 13, 5),
                senderId: "user2",
                isSent: false,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg5",
                content: "The build is passing now",
                timestamp: new Date(2025, 0, 2, 13, 15),
                senderId: "user3",
                isSent: false,
                status: 3,
                type: "text"
            }
        ],
        "conv3": [
            {
                messageId: "msg1",
                content: "Hey John, did you receive the documents?",
                timestamp: new Date(2025, 0, 2, 9, 30),
                senderId: "me",
                isSent: true,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg2",
                content: "Yes, I got them. Reviewing now.",
                timestamp: new Date(2025, 0, 2, 9, 45),
                senderId: "user4",
                isSent: false,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg3",
                content: "Let me know if you need any clarification",
                timestamp: new Date(2025, 0, 2, 9, 50),
                senderId: "me",
                isSent: true,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg4",
                content: "Got it, thanks!",
                timestamp: new Date(2025, 0, 2, 10, 0),
                senderId: "user4",
                isSent: false,
                status: 3,
                type: "text"
            }
        ],
        "conv4": [
            {
                messageId: "msg1",
                content: "Hi Emma!",
                timestamp: new Date(2025, 0, 1, 18, 30),
                senderId: "me",
                isSent: true,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg2",
                content: "Hey! How are you?",
                timestamp: new Date(2025, 0, 1, 18, 35),
                senderId: "user5",
                isSent: false,
                status: 3,
                type: "text"
            },
            {
                messageId: "msg3",
                content: "Are you free this weekend?",
                timestamp: new Date(2025, 0, 1, 18, 45),
                senderId: "user5",
                isSent: false,
                status: 3,
                type: "text"
            }
        ],
        "conv5": [
            {
                messageId: "msg1",
                content: "New feature released!",
                timestamp: new Date(2025, 0, 1, 9, 0),
                senderId: "system",
                isSent: false,
                status: 3,
                type: "text"
            }
        ]
    })

    function getConversations() {
        return conversations
    }

    function getMessages(conversationId) {
        return messages[conversationId] || []
    }

    function getConversation(conversationId) {
        for (let i = 0; i < conversations.length; i++) {
            if (conversations[i].conversationId === conversationId) {
                return conversations[i]
            }
        }
        return null
    }

    function formatTime(date) {
        if (!date) {
            return ""
        }

        let jsDate = date
        if (typeof date === "number") {
            jsDate = new Date(date)
        } else if (!(date instanceof Date)) {
            if (date.toMSecsSinceEpoch) {
                jsDate = new Date(date.toMSecsSinceEpoch())
            } else {
                return ""
            }
        }

        if (isNaN(jsDate.getTime())) {
            return ""
        }

        const now = new Date()
        const diff = now - jsDate
        const minutes = Math.floor(diff / 60000)
        const hours = Math.floor(diff / 3600000)
        const days = Math.floor(diff / 86400000)

        if (minutes < 1) return qsTr("Just now")
        if (minutes < 60) return minutes + qsTr(" min ago")
        if (hours < 24) return Qt.formatTime(jsDate, "hh:mm")
        if (days < 7) {
            const weekdays = [qsTr("Sun"), qsTr("Mon"), qsTr("Tue"), qsTr("Wed"), qsTr("Thu"), qsTr("Fri"), qsTr("Sat")]
            return weekdays[jsDate.getDay()]
        }
        return Qt.formatDate(jsDate, "MM/dd")
    }

    function formatMessageTime(date) {
        return Qt.formatTime(date, "hh:mm")
    }
}
