import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root

    property alias searchText: searchField.text

    signal settingsClicked()

    implicitHeight: 130
    color: ThemeManager.background

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Avatar {
                size: 44
                source: MockData.currentUser.avatar
                name: MockData.currentUser.name
                isOnline: true
                showStatus: false
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    text: MockData.currentUser.name
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: ThemeManager.textPrimary

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                Label {
                    text: qsTr("Online")
                    font.pixelSize: 12
                    color: ThemeManager.online
                }
            }

            IconButton {
                iconSource: "qrc:/qt/qml/ModernChat/resources/icons/settings.svg"
                animationType: "rotate"
                onClicked: root.settingsClicked()
            }
        }

        SearchField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: qsTr("Search conversations...")
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
