import QtQuick
import ModernChat

QtObject {
    id: root

    property string conversationId: ""
    property alias count: listModel.count

    property ListModel model: ListModel {
        id: listModel
    }

    function get(index) {
        return listModel.get(index)
    }

    function loadMessages(convId) {
        conversationId = convId
        listModel.clear()
        const messages = MockData.getMessages(convId)
        for (let i = 0; i < messages.length; i++) {
            listModel.append(messages[i])
        }
    }

    function sendMessage(content) {
        const timestamp = new Date()
        const msg = {
            messageId: "msg_" + Date.now(),
            content: content,
            timestamp: timestamp,
            senderId: "me",
            isSent: true,
            status: 0,
            type: "text"
        }
        listModel.append(msg)

        // Simulate sending delay
        sendTimer.messageIndex = listModel.count - 1
        sendTimer.start()

        return msg.messageId
    }

    property Timer sendTimer: Timer {
        id: sendTimer
        property int messageIndex: -1
        interval: 500
        onTriggered: {
            if (messageIndex >= 0 && messageIndex < listModel.count) {
                listModel.setProperty(messageIndex, "status", 1)
                deliverTimer.messageIndex = messageIndex
                deliverTimer.start()
            }
        }
    }

    property Timer deliverTimer: Timer {
        id: deliverTimer
        property int messageIndex: -1
        interval: 1000
        onTriggered: {
            if (messageIndex >= 0 && messageIndex < listModel.count) {
                listModel.setProperty(messageIndex, "status", 2)
                readTimer.messageIndex = messageIndex
                readTimer.start()
            }
        }
    }

    property Timer readTimer: Timer {
        id: readTimer
        property int messageIndex: -1
        interval: 1500
        onTriggered: {
            if (messageIndex >= 0 && messageIndex < listModel.count) {
                listModel.setProperty(messageIndex, "status", 3)
            }
        }
    }

    function receiveMessage(content) {
        const msg = {
            messageId: "msg_" + Date.now(),
            content: content,
            timestamp: new Date(),
            senderId: "other",
            isSent: false,
            status: 3,
            type: "text"
        }
        listModel.append(msg)
        return msg.messageId
    }

    function getMessageById(msgId) {
        for (let i = 0; i < listModel.count; i++) {
            if (listModel.get(i).messageId === msgId) {
                return listModel.get(i)
            }
        }
        return null
    }

    function updateMessageStatus(msgId, status) {
        for (let i = 0; i < listModel.count; i++) {
            if (listModel.get(i).messageId === msgId) {
                listModel.setProperty(i, "status", status)
                break
            }
        }
    }
}
