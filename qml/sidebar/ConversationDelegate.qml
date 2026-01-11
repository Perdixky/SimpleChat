import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ItemDelegate {
    id: root

    required property int index
    required property string conversationId
    required property string name
    required property string avatar
    required property string lastMessage
    required property var lastMessageTime
    required property int unreadCount
    required property bool isOnline
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
                    text: root.lastMessageTime ? MockData.formatTime(root.lastMessageTime) : ""
                    font.pixelSize: 12
                    color: root.unreadCount > 0 ? ThemeManager.accent : ThemeManager.textMuted

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
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
