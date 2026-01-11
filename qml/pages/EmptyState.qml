import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    color: ThemeManager.backgroundSecondary

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 80
            implicitHeight: 80
            radius: 40
            color: ThemeManager.accentLight

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }

            Image {
                anchors.centerIn: parent
                source: "qrc:/qt/qml/ModernChat/resources/icons/send.svg"
                sourceSize: Qt.size(32, 32)
                opacity: 0.7
            }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 1.05
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: 1.0
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Select a conversation")
            font.pixelSize: 20
            font.weight: Font.DemiBold
            color: ThemeManager.textPrimary

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Choose a conversation from the list to start chatting")
            font.pixelSize: 14
            color: ThemeManager.textSecondary

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }
    }
}
