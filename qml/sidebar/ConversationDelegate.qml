import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ItemDelegate {
    id: root

    required property int index
    property string conversationId: ""
    property string name: ""
    property string avatar: ""
    property string lastMessage: ""
    property var lastMessageTime: null
    property int unreadCount: 0
    property bool isOnline: false
    property bool isSelected: false

    signal selected(string id)

    hoverEnabled: false

    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse
    }

    width: ListView.view ? ListView.view.width : 320
    height: 72

    background: Rectangle {
        color: {
            if (root.isSelected) return ThemeManager.accentLight
            if (hoverHandler.hovered) return ThemeManager.surfaceHover
            return "transparent"
        }

        Rectangle {
            width: 3
            height: parent.height * 0.6
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            color: ThemeManager.accent
            visible: root.isSelected
            radius: 1.5

            scale: root.isSelected ? 1 : 0
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutBack
                }
            }
        }
    }

    contentItem: RowLayout {
        spacing: 12

        Avatar {
            size: 48
            source: root.avatar
            name: root.name
            isOnline: root.isOnline
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: root.name
                    font.pixelSize: 15
                    font.weight: root.unreadCount > 0 ? Font.DemiBold : Font.Normal
                    color: ThemeManager.textPrimary
                    elide: Text.ElideRight

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                Label {
                    text: root.lastMessageTime ? formatTime(root.lastMessageTime) : ""
                    font.pixelSize: 12
                    color: root.unreadCount > 0 ? ThemeManager.accent : ThemeManager.textMuted

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }

                    function formatTime(dateTime) {
                        if (!dateTime) return ""
                        const now = new Date()
                        const date = new Date(dateTime)
                        const diffMs = now - date
                        const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

                        if (diffDays === 0) {
                            return date.toLocaleTimeString(Qt.locale(), "hh:mm")
                        } else if (diffDays === 1) {
                            return qsTr("Yesterday")
                        } else if (diffDays < 7) {
                            return date.toLocaleDateString(Qt.locale(), "ddd")
                        } else {
                            return date.toLocaleDateString(Qt.locale(), "MM/dd")
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: root.lastMessage
                    font.pixelSize: 13
                    color: ThemeManager.textSecondary
                    elide: Text.ElideRight
                    maximumLineCount: 1

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                Badge {
                    count: root.unreadCount
                }
            }
        }
    }

    onClicked: selected(conversationId)

    scale: hoverHandler.hovered ? 1.01 : 1
    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
}
