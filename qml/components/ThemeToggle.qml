import QtQuick
import ModernChat
import QtQuick.Controls

AbstractButton {
    id: root

    implicitWidth: 48
    implicitHeight: 28

    background: Rectangle {
        radius: 14
        color: ThemeManager.isDark ? ThemeManager.accent : ThemeManager.border

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }

    contentItem: Item {
        Rectangle {
            id: handle
            x: ThemeManager.isDark ? parent.width - width - 4 : 4
            y: 4
            width: 20
            height: 20
            radius: 10
            color: "#ffffff"

            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Image {
                anchors.centerIn: parent
                source: ThemeManager.isDark
                        ? "qrc:/qt/qml/ModernChat/resources/icons/moon.svg"
                        : "qrc:/qt/qml/ModernChat/resources/icons/sun.svg"
                sourceSize: Qt.size(12, 12)

                rotation: ThemeManager.isDark ? 0 : 180
                Behavior on rotation {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }

                opacity: 0.8
            }
        }
    }

    onClicked: ThemeManager.toggle()

    scale: pressed ? 0.95 : 1
    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
}
