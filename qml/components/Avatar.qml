import QtQuick
import ModernChat

Item {
    id: root

    property int size: 48
    property string source: ""
    property string name: ""
    property bool isOnline: false
    property bool showStatus: true

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: avatarContainer
        anchors.fill: parent
        radius: width / 2
        color: ThemeManager.backgroundTertiary
        clip: true

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }

        Image {
            id: avatarImage
            anchors.fill: parent
            source: root.source
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: avatarImage.status !== Image.Ready && root.name !== ""
            text: root.name.charAt(0).toUpperCase()
            font.pixelSize: root.size * 0.4
            font.weight: Font.DemiBold
            color: ThemeManager.accent

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }

        Image {
            anchors.centerIn: parent
            visible: avatarImage.status !== Image.Ready && root.name === ""
            source: "qrc:/qt/qml/ModernChat/resources/icons/user.svg"
            sourceSize: Qt.size(root.size * 0.5, root.size * 0.5)
            opacity: 0.5
        }
    }

    Rectangle {
        id: statusIndicator
        visible: root.showStatus
        width: root.size * 0.25
        height: width
        radius: width / 2
        color: root.isOnline ? ThemeManager.online : ThemeManager.offline
        border.width: 2
        border.color: ThemeManager.background

        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 0
            bottomMargin: 0
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        Behavior on border.color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }

        scale: root.isOnline ? 1 : 0.8
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }
    }
}
