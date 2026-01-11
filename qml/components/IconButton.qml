import QtQuick
import ModernChat
import QtQuick.Controls

AbstractButton {
    id: root

    property alias iconSource: iconImage.source
    property int iconSize: 20
    property color iconColor: ThemeManager.textSecondary
    property color hoverColor: ThemeManager.textPrimary
    property color backgroundColor: "transparent"
    property color hoverBackgroundColor: ThemeManager.surfaceHover
    property int radius: 8
    property bool showBackground: true
    // 动画类型: "none", "search", "rotate", "menu"
    property string animationType: "none"

    implicitWidth: 40
    implicitHeight: 40
    hoverEnabled: false

    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse
        onHoveredChanged: {
            if (hovered && root.animationType !== "none") {
                playAnimation()
            }
        }
    }

    function playAnimation() {
        if (animationType === "search") {
            searchAnimation.restart()
        } else if (animationType === "rotate") {
            rotateAnimation.restart()
        } else if (animationType === "menu") {
            menuAnimation.restart()
        }
    }

    Component.onCompleted: {
        if (animationType !== "none") {
            appearTimer.start()
        }
    }

    Timer {
        id: appearTimer
        interval: 100
        onTriggered: playAnimation()
    }

    background: Rectangle {
        visible: root.showBackground
        radius: root.radius
        color: hoverHandler.hovered || root.pressed ? root.hoverBackgroundColor : root.backgroundColor
    }

    contentItem: Item {
        Image {
            id: iconImage
            anchors.centerIn: parent
            sourceSize: Qt.size(root.iconSize, root.iconSize)
            opacity: root.enabled ? (hoverHandler.hovered ? 0.9 : 0.7) : 0.4

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }

            // 搜索动画：放大后回弹
            SequentialAnimation {
                id: searchAnimation
                NumberAnimation {
                    target: iconImage
                    property: "scale"
                    from: 1
                    to: 1.3
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: iconImage
                    property: "scale"
                    from: 1.3
                    to: 1
                    duration: 200
                    easing.type: Easing.OutBack
                }
            }

            // 旋转动画：齿轮旋转
            SequentialAnimation {
                id: rotateAnimation
                NumberAnimation {
                    target: iconImage
                    property: "rotation"
                    from: 0
                    to: 180
                    duration: 400
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: iconImage
                    property: "rotation"
                    from: 180
                    to: 360
                    duration: 0
                }
            }

            // 菜单动画：缩放+轻微旋转
            ParallelAnimation {
                id: menuAnimation
                SequentialAnimation {
                    NumberAnimation {
                        target: iconImage
                        property: "scale"
                        from: 0.5
                        to: 1.1
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: iconImage
                        property: "scale"
                        from: 1.1
                        to: 1
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: iconImage
                        property: "rotation"
                        from: -90
                        to: 5
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: iconImage
                        property: "rotation"
                        from: 5
                        to: 0
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    scale: pressed ? 0.9 : (hoverHandler.hovered ? 1.03 : 1)

    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }
}
