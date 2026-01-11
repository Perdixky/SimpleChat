import QtQuick
import ModernChat
import QtQuick.Layouts

Rectangle {
    id: root

    property alias currentConversationId: conversationList.currentConversationId

    signal conversationSelected(string id)
    signal settingsClicked()

    color: ThemeManager.background

    Behavior on color {
        ColorAnimation { duration: ThemeManager.transitionDuration }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SidebarHeader {
            id: header
            Layout.fillWidth: true
            onSettingsClicked: root.settingsClicked()
        }

        ConversationList {
            id: conversationList
            Layout.fillWidth: true
            Layout.fillHeight: true
            searchText: header.searchText

            onConversationSelected: (id) => {
                root.conversationSelected(id)
            }
        }
    }
}
