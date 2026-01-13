import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property string content
    required property string timestamp
    required property bool isSent
    property int status: 0  // 0: sending, 1: sent, 2: delivered, 3: read
    property string senderName: ""

    implicitWidth: parent ? parent.width : 300
    implicitHeight: bubble.height + 8

    opacity: 0
    scale: 0.8
    transformOrigin: root.isSent ? Item.Right : Item.Left

    Component.onCompleted: {
        enterAnimation.start()
    }

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation {
            target: root
            property: "opacity"
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Rectangle {
        id: bubble

        anchors {
            left: root.isSent ? undefined : parent.left
            right: root.isSent ? parent.right : undefined
            leftMargin: root.isSent ? 60 : 16
            rightMargin: root.isSent ? 16 : 60
        }

        width: Math.min(contentLayout.implicitWidth + 24, parent.width - 76)
        height: contentLayout.implicitHeight + 16

        color: root.isSent ? ThemeManager.bubbleSent : ThemeManager.bubbleReceived
        radius: 18

        scale: bubbleHoverHandler.hovered ? 1.02 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }

        HoverHandler {
            id: bubbleHoverHandler
            acceptedDevices: PointerDevice.Mouse
        }

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }

        ColumnLayout {
            id: contentLayout
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 4

            Label {
                visible: !root.isSent && root.senderName !== ""
                text: root.senderName
                color: ThemeManager.accent
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            Label {
                Layout.fillWidth: true
                text: root.content
                color: root.isSent ? ThemeManager.bubbleSentText : ThemeManager.bubbleReceivedText
                wrapMode: Text.WordWrap
                font.pixelSize: 14

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 4

                Label {
                    text: root.timestamp
                    font.pixelSize: 11
                    color: root.isSent ? Qt.rgba(1, 1, 1, 0.7) : ThemeManager.textMuted

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                Image {
                    visible: root.isSent
                    source: root.status >= 2
                            ? "qrc:/qt/qml/ModernChat/resources/icons/check-double.svg"
                            : "qrc:/qt/qml/ModernChat/resources/icons/check.svg"
                    sourceSize: Qt.size(14, 14)
                    opacity: root.status === 0 ? 0.4 : (root.status === 3 ? 1 : 0.6)
                }
            }
        }
    }

}
