pragma ComponentBehavior: Bound
import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string homeServer: "chat.neboer.site"

    signal loginRequested(string server, string username, string password)
    signal createAccountRequested()

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.background

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }
    }

    // 登录卡片
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: Math.min(400, parent.width - 48)
        height: contentColumn.height + 64
        radius: 16
        color: ThemeManager.surface
        border.width: 1
        border.color: ThemeManager.border

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }
        Behavior on border.color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }

        ColumnLayout {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 32
            }
            spacing: 24

            // 标题
            Label {
                Layout.fillWidth: true
                text: qsTr("登录")
                font.pixelSize: 28
                font.weight: Font.Bold
                color: ThemeManager.textPrimary
                horizontalAlignment: Text.AlignHCenter

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }
            }

            // 家服务器区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("家服务器")
                        font.pixelSize: 14
                        color: ThemeManager.textSecondary

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // 编辑按钮
                    Label {
                        text: qsTr("编辑")
                        font.pixelSize: 14
                        color: ThemeManager.accent
                        opacity: serverEditArea.containsMouse ? 0.8 : 1

                        MouseArea {
                            id: serverEditArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: serverEditDialog.open()
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }
                    }
                }

                // 服务器地址显示
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 12
                    color: ThemeManager.backgroundSecondary
                    border.width: 1
                    border.color: ThemeManager.border

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }

                    Label {
                        anchors {
                            left: parent.left
                            leftMargin: 16
                            verticalCenter: parent.verticalCenter
                        }
                        text: root.homeServer
                        font.pixelSize: 14
                        color: ThemeManager.textPrimary

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }
                    }
                }
            }

            // 用户名输入框
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: qsTr("用户名")
                    font.pixelSize: 14
                    color: ThemeManager.textSecondary

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 12
                    color: ThemeManager.backgroundSecondary
                    border.width: usernameField.activeFocus ? 2 : 1
                    border.color: usernameField.activeFocus ? ThemeManager.accent : ThemeManager.border

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    Behavior on border.width {
                        NumberAnimation { duration: 150 }
                    }

                    TextField {
                        id: usernameField
                        anchors {
                            fill: parent
                            leftMargin: 16
                            rightMargin: 16
                        }
                        placeholderText: qsTr("用户名")
                        placeholderTextColor: ThemeManager.textMuted
                        color: ThemeManager.textPrimary
                        font.pixelSize: 14
                        selectByMouse: true
                        background: null

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }
                    }
                }
            }

            // 密码输入框
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: qsTr("密码")
                    font.pixelSize: 14
                    color: ThemeManager.textSecondary

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 12
                    color: ThemeManager.backgroundSecondary
                    border.width: passwordField.activeFocus ? 2 : 1
                    border.color: passwordField.activeFocus ? ThemeManager.accent : ThemeManager.border

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    Behavior on border.width {
                        NumberAnimation { duration: 150 }
                    }

                    TextField {
                        id: passwordField
                        anchors {
                            fill: parent
                            leftMargin: 16
                            rightMargin: 16
                        }
                        placeholderText: qsTr("密码")
                        placeholderTextColor: ThemeManager.textMuted
                        color: ThemeManager.textPrimary
                        font.pixelSize: 14
                        echoMode: TextInput.Password
                        selectByMouse: true
                        background: null

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }

                        onAccepted: loginButton.clicked()
                    }
                }
            }

            // 错误信息显示
            Label {
                Layout.fillWidth: true
                text: login.errorMessage
                font.pixelSize: 13
                color: "#ef4444"
                wrapMode: Text.WordWrap
                visible: login.errorMessage !== ""
                horizontalAlignment: Text.AlignHCenter

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            // 登录按钮
            Rectangle {
                id: loginButton
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: login.isLoading ? ThemeManager.textMuted :
                       (loginButtonArea.containsMouse ? ThemeManager.accentHover : ThemeManager.accent)
                enabled: !login.isLoading

                signal clicked()

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    BusyIndicator {
                        width: 20
                        height: 20
                        running: login.isLoading
                        visible: login.isLoading
                    }

                    Label {
                        text: login.isLoading ? qsTr("登录中...") : qsTr("登录")
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                }

                MouseArea {
                    id: loginButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: login.isLoading ? Qt.BusyCursor : Qt.PointingHandCursor
                    onClicked: {
                        if (!login.isLoading) {
                            loginButton.clicked()
                            login.loginRequest(root.homeServer, usernameField.text, passwordField.text)
                        }
                    }
                }

                scale: loginButtonArea.pressed && !login.isLoading ? 0.98 : 1

                Behavior on scale {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }
            }

            // 创建账户链接
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 4

                Item { Layout.fillWidth: true }

                Label {
                    text: qsTr("新来的?")
                    font.pixelSize: 14
                    color: ThemeManager.textSecondary

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                Label {
                    text: qsTr("创建账户")
                    font.pixelSize: 14
                    color: ThemeManager.accent
                    opacity: createAccountArea.containsMouse ? 0.8 : 1

                    MouseArea {
                        id: createAccountArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.createAccountRequested()
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    // 主题切换按钮
    ThemeToggle {
        anchors {
            top: parent.top
            right: parent.right
            margins: 16
        }
    }

    // 服务器编辑对话框
    Dialog {
        id: serverEditDialog
        anchors.centerIn: parent
        width: Math.min(360, root.width - 48)
        modal: true
        title: qsTr("编辑家服务器")

        background: Rectangle {
            radius: 16
            color: ThemeManager.surface
            border.width: 1
            border.color: ThemeManager.border

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
            Behavior on border.color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }

        header: Label {
            text: serverEditDialog.title
            font.pixelSize: 18
            font.weight: Font.Bold
            color: ThemeManager.textPrimary
            padding: 24
            bottomPadding: 0

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }

        contentItem: ColumnLayout {
            spacing: 16

            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 12
                color: ThemeManager.backgroundSecondary
                border.width: serverEditField.activeFocus ? 2 : 1
                border.color: serverEditField.activeFocus ? ThemeManager.accent : ThemeManager.border

                Behavior on color {
                    ColorAnimation { duration: ThemeManager.transitionDuration }
                }
                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }

                TextField {
                    id: serverEditField
                    anchors {
                        fill: parent
                        leftMargin: 16
                        rightMargin: 16
                    }
                    text: root.homeServer
                    placeholderText: qsTr("例如: matrix.org")
                    placeholderTextColor: ThemeManager.textMuted
                    color: ThemeManager.textPrimary
                    font.pixelSize: 14
                    selectByMouse: true
                    background: null

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 10
                    color: cancelButtonArea.containsMouse ? ThemeManager.surfaceHover : ThemeManager.backgroundSecondary
                    border.width: 1
                    border.color: ThemeManager.border

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("取消")
                        font.pixelSize: 14
                        color: ThemeManager.textPrimary

                        Behavior on color {
                            ColorAnimation { duration: ThemeManager.transitionDuration }
                        }
                    }

                    MouseArea {
                        id: cancelButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: serverEditDialog.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 10
                    color: confirmButtonArea.containsMouse ? ThemeManager.accentHover : ThemeManager.accent

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("确认")
                        font.pixelSize: 14
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: confirmButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.homeServer = serverEditField.text
                            serverEditDialog.close()
                        }
                    }
                }
            }
        }

        footer: Item { height: 24 }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 200; easing.type: Easing.OutCubic }
            }
        }

        exit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
                NumberAnimation { property: "scale"; from: 1; to: 0.9; duration: 150; easing.type: Easing.InCubic }
            }
        }
    }
}
