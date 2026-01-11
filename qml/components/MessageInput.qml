import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    signal messageSent(string message)

    implicitHeight: Math.min(inputArea.implicitHeight + 24, 150)
    color: ThemeManager.surface
    radius: 24

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 8
            topMargin: 4
            bottomMargin: 4
        }
        spacing: 4

        IconButton {
            iconSource: "qrc:/qt/qml/ModernChat/resources/icons/emoji.svg"
            iconSize: 22
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        IconButton {
            iconSource: "qrc:/qt/qml/ModernChat/resources/icons/attachment.svg"
            iconSize: 22
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            TextArea {
                id: inputArea
                placeholderText: qsTr("Type a message...")
                placeholderTextColor: ThemeManager.textMuted
                color: ThemeManager.textPrimary
                font.pixelSize: 14
                wrapMode: TextArea.Wrap
                selectByMouse: true

                background: null

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }

                Keys.onReturnPressed: (event) => {
                    if (event.modifiers & Qt.ShiftModifier) {
                        event.accepted = false
                    } else {
                        root.sendMessage()
                        event.accepted = true
                    }
                }
            }
        }

        IconButton {
            id: sendButton
            iconSource: "qrc:/qt/qml/ModernChat/resources/icons/send.svg"
            iconSize: 22
            iconColor: "#ffffff"
            hoverColor: "#ffffff"
            backgroundColor: ThemeManager.accent
            hoverBackgroundColor: ThemeManager.accentHover
            radius: 20
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4

            visible: inputArea.text.trim().length > 0
            opacity: visible ? 1 : 0
            scale: visible ? 1 : 0.5

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutBack
                }
            }

            onClicked: root.sendMessage()
        }
    }

    function sendMessage() {
        const msg = inputArea.text.trim()
        if (msg.length > 0) {
            root.messageSent(msg)
            inputArea.clear()
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 1
        color: ThemeManager.border
        opacity: 0.5

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }
    }
}
