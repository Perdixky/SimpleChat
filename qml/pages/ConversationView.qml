pragma ComponentBehavior: Bound
import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root

    property string conversationId: ""
    property var conversation: null
    property bool showTypingIndicator: false

    signal backClicked()

    color: ThemeManager.backgroundSecondary

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    onConversationIdChanged: {
        if (root.conversationId !== "") {
            conversation = MockData.getConversation(root.conversationId)
            messageModel.loadMessages(root.conversationId)
            messageList.positionViewAtEnd()
        }
    }

    MessageModel {
        id: messageModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: ThemeManager.surface

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 12

                IconButton {
                    visible: parent.width < 600
                    iconSource: "qrc:/qt/qml/ModernChat/resources/icons/arrow-left.svg"
                    onClicked: root.backClicked()
                }

                Avatar {
                    size: 40
                    source: root.conversation ? root.conversation.avatar : ""
                    name: root.conversation ? root.conversation.name : ""
                    isOnline: root.conversation ? root.conversation.isOnline : false
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: root.conversation ? root.conversation.name : ""
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: ThemeManager.textPrimary
                        elide: Text.ElideRight

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }
                    }

                    Label {
                        text: {
                            if (root.showTypingIndicator) return qsTr("typing...")
                            if (root.conversation && root.conversation.isOnline) return qsTr("Online")
                            return qsTr("Offline")
                        }
                        font.pixelSize: 12
                        color: {
                            if (root.showTypingIndicator) return ThemeManager.accent
                            if (root.conversation && root.conversation.isOnline) return ThemeManager.online
                            return ThemeManager.textMuted
                        }

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                }

                IconButton {
                    iconSource: "qrc:/qt/qml/ModernChat/resources/icons/search.svg"
                    animationType: "search"
                }

                IconButton {
                    iconSource: "qrc:/qt/qml/ModernChat/resources/icons/menu.svg"
                    animationType: "menu"
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 1
                color: ThemeManager.divider

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }
            }
        }

        // Message List
        ListView {
            id: messageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds

            model: messageModel.model

            delegate: Item {
                id: msgDelegate
                required property int index
                required property string content
                required property var timestamp
                required property bool isSent
                required property int status

                width: messageList.width
                height: bubble.height

                MessageBubble {
                    id: bubble
                    width: parent.width
                    content: msgDelegate.content
                    timestamp: msgDelegate.timestamp ? MockData.formatMessageTime(msgDelegate.timestamp) : ""
                    isSent: msgDelegate.isSent
                    status: msgDelegate.status
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

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            footer: Item {
                width: messageList.width
                height: typingIndicator.visible ? 48 : 0

                Behavior on height {
                    NumberAnimation { duration: 200 }
                }

                TypingIndicator {
                    id: typingIndicator
                    visible: root.showTypingIndicator
                    anchors {
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            onCountChanged: {
                Qt.callLater(() => {
                    messageList.positionViewAtEnd()
                })
            }
        }

        // Input Area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: messageInput.implicitHeight + 16
            color: ThemeManager.background

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }

            MessageInput {
                id: messageInput
                anchors {
                    fill: parent
                    margins: 8
                }

                onMessageSent: (message) => {
                    messageModel.sendMessage(message)

                    // Simulate typing response
                    root.showTypingIndicator = true
                    responseTimer.start()
                }
            }
        }
    }

    Timer {
        id: responseTimer
        interval: 2000
        onTriggered: {
            root.showTypingIndicator = false

            // Simulate receiving a response
            const responses = [
                "That's interesting!",
                "I see what you mean.",
                "Let me think about that...",
                "Great point!",
                "Thanks for sharing!"
            ]
            const randomResponse = responses[Math.floor(Math.random() * responses.length)]
            messageModel.receiveMessage(randomResponse)
        }
    }
}
