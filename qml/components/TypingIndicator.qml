import QtQuick
import ModernChat
import QtQuick.Layouts

Rectangle {
    id: root

    implicitWidth: 60
    implicitHeight: 32
    radius: 16
    color: ThemeManager.bubbleReceived

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    opacity: 0
    scale: 0.8

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
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1
            duration: 250
            easing.type: Easing.OutBack
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: 3

            Rectangle {
                id: dot
                required property int index
                width: 8
                height: 8
                radius: 4
                color: ThemeManager.textMuted

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    PauseAnimation { duration: dot.index * 150 }
                    NumberAnimation {
                        from: 0
                        to: -6
                        duration: 300
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: -6
                        to: 0
                        duration: 300
                        easing.type: Easing.InOutSine
                    }
                    PauseAnimation { duration: (2 - dot.index) * 150 + 300 }
                }
            }
        }
    }
}
