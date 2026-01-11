import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property alias text: textField.text
    property alias placeholderText: textField.placeholderText

    signal accepted()

    implicitWidth: 200
    implicitHeight: 40
    radius: 20
    color: ThemeManager.backgroundSecondary

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 8

        Image {
            source: "qrc:/qt/qml/ModernChat/resources/icons/search.svg"
            sourceSize: Qt.size(18, 18)
            opacity: textField.activeFocus ? 0.8 : 0.5

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        TextField {
            id: textField
            Layout.fillWidth: true
            placeholderText: qsTr("Search...")
            placeholderTextColor: ThemeManager.textMuted
            color: ThemeManager.textPrimary
            font.pixelSize: 14
            selectByMouse: true

            background: null

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }

            onAccepted: root.accepted()
        }

        IconButton {
            visible: textField.text.length > 0
            iconSource: "qrc:/qt/qml/ModernChat/resources/icons/close.svg"
            iconSize: 14
            implicitWidth: 24
            implicitHeight: 24
            radius: 12

            opacity: visible ? 1 : 0
            scale: visible ? 1 : 0.5

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
            Behavior on scale {
                NumberAnimation { duration: 150; easing.type: Easing.OutBack }
            }

            onClicked: textField.clear()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: textField.activeFocus ? 2 : 0
        border.color: ThemeManager.accent

        Behavior on border.width {
            NumberAnimation { duration: 150 }
        }
    }
}
