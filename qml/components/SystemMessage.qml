import QtQuick
import QtQuick.Controls
import ModernChat

Item {
    id: root

    required property string content

    implicitWidth: parent ? parent.width : label.implicitWidth
    implicitHeight: content === "" ? 0 : pill.height + 12

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        y: 6
        width: Math.min(root.width - 32, label.implicitWidth + 20)
        height: label.implicitHeight + 8
        radius: height / 2
        color: ThemeManager.backgroundTertiary
        opacity: 0.85
        visible: root.content !== ""

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }
    }

    Label {
        id: label
        anchors.centerIn: pill
        width: pill.width - 12
        text: root.content
        color: ThemeManager.textMuted
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 12
        visible: root.content !== ""

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }
    }
}
