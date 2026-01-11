import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root

    signal close()

    color: ThemeManager.background

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: ThemeManager.surface

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 8
                    rightMargin: 16
                }

                IconButton {
                    iconSource: "qrc:/qt/qml/ModernChat/resources/icons/arrow-left.svg"
                    onClicked: root.close()
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Settings")
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: ThemeManager.textPrimary

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 1
                color: ThemeManager.divider

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }
            }
        }

        // Content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 24

                Item { Layout.preferredHeight: 8 }

                // Appearance Section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 8

                    Label {
                        text: qsTr("Appearance")
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: ThemeManager.accent
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: settingsColumn1.height
                        radius: 12
                        color: ThemeManager.surface

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }

                        ColumnLayout {
                            id: settingsColumn1
                            width: parent.width
                            spacing: 0

                            SettingsItem {
                                text: qsTr("Dark Mode")
                                trailing: ThemeToggle {}
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                                implicitHeight: 1
                                color: ThemeManager.divider

                                Behavior on color {
                                    ColorAnimation { duration: ThemeManager.transitionDuration }
                                }
                            }

                            SettingsItem {
                                text: qsTr("Accent Color")
                                trailing: Row {
                                    spacing: 8
                                    Repeater {
                                        model: ["#6366f1", "#8b5cf6", "#ec4899", "#f59e0b", "#10b981"]

                                        Rectangle {
                                            id: colorSwatch
                                            required property color modelData
                                            width: 24
                                            height: 24
                                            radius: 12
                                            color: colorSwatch.modelData
                                            border.width: ThemeManager.accent === colorSwatch.modelData ? 2 : 0
                                            border.color: ThemeManager.textPrimary

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    // Future: accent color change
                                                }
                                            }

                                            scale: colorHoverHandler.hovered ? 1.1 : 1
                                            Behavior on scale {
                                                NumberAnimation { duration: 100 }
                                            }

                                            HoverHandler {
                                                id: colorHoverHandler
                                                acceptedDevices: PointerDevice.Mouse
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Notifications Section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 8

                    Label {
                        text: qsTr("Notifications")
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: ThemeManager.accent
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: settingsColumn2.height
                        radius: 12
                        color: ThemeManager.surface

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }

                        ColumnLayout {
                            id: settingsColumn2
                            width: parent.width
                            spacing: 0

                            SettingsItem {
                                text: qsTr("Enable Notifications")
                                trailing: Switch {
                                    checked: true
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                                implicitHeight: 1
                                color: ThemeManager.divider

                                Behavior on color {
                                    ColorAnimation { duration: ThemeManager.transitionDuration }
                                }
                            }

                            SettingsItem {
                                text: qsTr("Sound")
                                trailing: Switch {
                                    checked: true
                                }
                            }
                        }
                    }
                }

                // About Section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 8

                    Label {
                        text: qsTr("About")
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: ThemeManager.accent
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: settingsColumn3.height
                        radius: 12
                        color: ThemeManager.surface

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }

                        ColumnLayout {
                            id: settingsColumn3
                            width: parent.width
                            spacing: 0

                            SettingsItem {
                                text: qsTr("Version")
                                trailing: Label {
                                    text: "1.0.0"
                                    color: ThemeManager.textSecondary
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                                implicitHeight: 1
                                color: ThemeManager.divider

                                Behavior on color {
                                    ColorAnimation { duration: ThemeManager.transitionDuration }
                                }
                            }

                            SettingsItem {
                                text: qsTr("Built with Qt 6 & QML")
                                trailing: Label {
                                    text: "Made with love"
                                    color: ThemeManager.textMuted
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 24 }
            }
        }
    }

    component SettingsItem: ItemDelegate {
        id: settingsItem
        property alias trailing: trailingContainer.children

        Layout.fillWidth: true
        height: 56
        leftPadding: 16
        rightPadding: 16
        hoverEnabled: false

        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
        }

        background: Rectangle {
            color: hoverHandler.hovered ? ThemeManager.surfaceHover : "transparent"
        }

        contentItem: RowLayout {
            Label {
                Layout.fillWidth: true
                text: settingsItem.text
                color: ThemeManager.textPrimary
                font.pixelSize: 15

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }
            }

            Row {
                id: trailingContainer
            }
        }
    }
}
