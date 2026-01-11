import QtQuick
import ModernChat
import QtQuick.Controls

Rectangle {
    id: root

    property int count: 0
    property int maxCount: 99

    visible: count > 0

    implicitWidth: Math.max(20, countLabel.implicitWidth + 10)
    implicitHeight: 20
    radius: height / 2

    color: ThemeManager.accent

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    Label {
        id: countLabel
        anchors.centerIn: parent
        text: root.count > root.maxCount ? root.maxCount + "+" : root.count.toString()
        font.pixelSize: 11
        font.weight: Font.DemiBold
        color: "#ffffff"
    }

    scale: count > 0 ? 1 : 0

    Behavior on scale {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 1.5
        }
    }

    SequentialAnimation on scale {
        id: pulseAnimation
        running: false
        loops: 1
        NumberAnimation { to: 1.2; duration: 100 }
        NumberAnimation { to: 1.0; duration: 150; easing.type: Easing.OutBack }
    }

    onCountChanged: {
        if (count > 0) {
            pulseAnimation.start()
        }
    }
}
