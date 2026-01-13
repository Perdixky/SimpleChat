pragma ComponentBehavior: Bound
import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root

    property string conversationId: ""
    property var currentRoom: null
    property bool showTypingIndicator: false

    signal backClicked()

    color: ThemeManager.backgroundSecondary

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
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
                    source: ""
                    name: root.currentRoom ? root.currentRoom.displayName : ""
                    isOnline: connection.isOnline
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: root.currentRoom ? root.currentRoom.displayName : ""
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
                            if (connection.isOnline) return qsTr("Online")
                            return qsTr("Offline")
                        }
                        font.pixelSize: 12
                        color: {
                            if (root.showTypingIndicator) return ThemeManager.accent
                            if (connection.isOnline) return ThemeManager.online
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

            model: root.currentRoom

            delegate: Item {
                id: msgDelegate
                required property int index
                required property var event

                width: messageList.width
                height: msgDelegate.showDelegate ? contentLoader.implicitHeight : 0
                visible: msgDelegate.showDelegate

                readonly property bool isNotice: msgDelegate.event.type === EventEnums.Message
                                                   && msgDelegate.event.message.msgType === EventEnums.MsgType.Notice
                readonly property bool isState: msgDelegate.event.type === EventEnums.State
                readonly property string systemText: {
                    if (msgDelegate.isNotice) return msgDelegate.event.message.plainBody
                    if (msgDelegate.isState) return msgDelegate.event.state.summary
                    return ""
                }
                readonly property bool showSystem: msgDelegate.systemText !== ""
                readonly property bool showBubble: !msgDelegate.showSystem
                                                   && (msgDelegate.event.type === EventEnums.Message
                                                       || msgDelegate.event.type === EventEnums.Sticker)
                readonly property bool showDelegate: msgDelegate.showSystem || msgDelegate.showBubble

                Loader {
                    id: contentLoader
                    width: parent.width
                    sourceComponent: msgDelegate.showSystem
                                     ? systemMessageComponent
                                     : (msgDelegate.showBubble ? bubbleComponent : null)
                }

                Component {
                    id: systemMessageComponent

                    SystemMessage {
                        width: msgDelegate.width
                        content: msgDelegate.systemText
                    }
                }

                Component {
                    id: bubbleComponent

                    MessageBubble {
                        width: msgDelegate.width
                        content: {
                            if (msgDelegate.event.type === EventEnums.Message)
                                return msgDelegate.event.message.plainBody
                            if (msgDelegate.event.type === EventEnums.Sticker)
                                return msgDelegate.event.sticker.body
                            return ""
                        }
                        timestamp: formatTime(msgDelegate.event.timestamp)
                        isSent: msgDelegate.event.sender === connection.userId
                        status: 2  // delivered
                        senderName: msgDelegate.event.senderDisplayName

                        function formatTime(dateTime) {
                            if (!dateTime) return ""
                            const date = new Date(dateTime)
                            return date.toLocaleTimeString(Qt.locale(), "hh:mm")
                        }
                    }
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
                    if (root.conversationId !== "") {
                        roomList.sendMessage(root.conversationId, message)
                    }
                }
            }
        }
    }
}
