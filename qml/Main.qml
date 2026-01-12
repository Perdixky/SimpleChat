pragma ComponentBehavior: Bound
import QtQuick
import ModernChat
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "sidebar"
import "pages"

ApplicationWindow {
    id: root

    width: 1200
    height: 800
    minimumWidth: 400
    minimumHeight: 500
    visible: true
    title: qsTr("Modern Chat")

    // 登录状态
    property bool isLoggedIn: false

    // 平台检测
    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isDesktop: !isAndroid

    // 条件窗口标志 - Android不使用无边框
    flags: isDesktop ? (Qt.FramelessWindowHint | Qt.Window) : Qt.Window
    color: isDesktop ? "transparent" : ThemeManager.background

    readonly property bool isCompact: width < 900
    readonly property bool isMobile: width < 600 || isAndroid
    readonly property int windowRadius: isDesktop && root.visibility !== Window.Maximized ? 12 : 0

    // SafeArea (Qt 6.9+) - Android状态栏和导航栏适配
    readonly property real safeAreaTop: isAndroid ? SafeArea.margins.top : 0
    readonly property real safeAreaBottom: isAndroid ? SafeArea.margins.bottom : 0
    readonly property real safeAreaLeft: isAndroid ? SafeArea.margins.left : 0
    readonly property real safeAreaRight: isAndroid ? SafeArea.margins.right : 0

    property string currentConversationId: ""

    Rectangle {
        id: windowMask
        anchors.fill: windowContainer
        radius: root.windowRadius
        color: "white"
        antialiasing: true
        visible: root.isDesktop
    }

    ShaderEffectSource {
        id: windowMaskSource
        sourceItem: windowMask
        hideSource: true
        live: true
        smooth: true
        visible: root.isDesktop
    }

    // 圆角窗口容器
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        // 桌面端使用窗口边距，Android端使用SafeArea
        anchors.topMargin: root.safeAreaTop + (root.isDesktop && root.visibility !== Window.Maximized ? 1 : 0)
        anchors.bottomMargin: root.safeAreaBottom + (root.isDesktop && root.visibility !== Window.Maximized ? 1 : 0)
        anchors.leftMargin: root.safeAreaLeft + (root.isDesktop && root.visibility !== Window.Maximized ? 1 : 0)
        anchors.rightMargin: root.safeAreaRight + (root.isDesktop && root.visibility !== Window.Maximized ? 1 : 0)
        radius: root.windowRadius
        color: ThemeManager.background
        clip: true
        layer.enabled: root.windowRadius > 0 && root.isDesktop
        layer.smooth: true
        layer.samples: 4
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: windowMaskSource
        }

        Behavior on color {
            ColorAnimation { duration: ThemeManager.transitionDuration }
        }

        // 窗口边框 (仅桌面端)
        Rectangle {
            anchors.fill: parent
            radius: root.windowRadius
            color: "transparent"
            border.width: root.isDesktop ? 1 : 0
            border.color: ThemeManager.border
            visible: root.isDesktop

            Behavior on border.color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }

        // 窗口拖动和调整大小 (仅桌面端)
        MouseArea {
            id: resizeArea
            anchors.fill: parent
            hoverEnabled: root.isDesktop
            enabled: root.isDesktop

            property int edgeSize: 8
            property int edges: 0

            onPositionChanged: (mouse) => {
                if (!root.isDesktop || root.visibility === Window.Maximized) return
                edges = 0
                if (mouse.x < edgeSize) edges |= Qt.LeftEdge
                if (mouse.x > width - edgeSize) edges |= Qt.RightEdge
                if (mouse.y < edgeSize) edges |= Qt.TopEdge
                if (mouse.y > height - edgeSize) edges |= Qt.BottomEdge

                if (edges) {
                    cursorShape = Qt.SizeAllCursor
                } else {
                    cursorShape = Qt.ArrowCursor
                }
            }

            onPressed: (mouse) => {
                if (edges && root.visibility !== Window.Maximized) {
                    root.startSystemResize(edges)
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 自定义标题栏 (仅桌面端)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.isDesktop ? 36 : 0
                color: "transparent"
                visible: root.isDesktop

                // 圆角顶部背景
                Rectangle {
                    anchors.fill: parent
                    color: ThemeManager.background
                    radius: root.windowRadius

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: parent.radius
                        color: parent.color
                    }

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                // 拖动区域
                MouseArea {
                    anchors {
                        fill: parent
                        rightMargin: windowControls.width
                    }

                    property point clickPos

                    onPressed: (mouse) => {
                        clickPos = Qt.point(mouse.x, mouse.y)
                    }

                    onPositionChanged: (mouse) => {
                        if (pressed && root.visibility !== Window.Maximized) {
                            root.x += mouse.x - clickPos.x
                            root.y += mouse.y - clickPos.y
                        }
                    }

                    onDoubleClicked: {
                        if (root.visibility === Window.Maximized) {
                            root.showNormal()
                        } else {
                            root.showMaximized()
                        }
                    }
                }

                // 标题
                Label {
                    anchors {
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                    text: root.title
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: ThemeManager.textPrimary

                    Behavior on color {
                        ColorAnimation { duration: ThemeManager.transitionDuration }
                    }
                }

                // 窗口控制按钮
                Row {
                    id: windowControls
                    anchors {
                        right: parent.right
                        rightMargin: root.windowRadius > 0 ? 4 : 0
                        top: parent.top
                        topMargin: root.windowRadius > 0 ? 4 : 0
                    }
                    height: parent.height - (root.windowRadius > 0 ? 4 : 0)

                    Repeater {
                        model: [
                            { icon: "─", isClose: false },
                            { icon: root.visibility === Window.Maximized ? "❐" : "□", isClose: false },
                            { icon: "×", isClose: true }
                        ]

                        delegate: Rectangle {
                            id: windowControlButton
                            required property string icon
                            required property bool isClose
                            required property int index

                            width: 40
                            height: parent.height
                            radius: windowControlButton.isClose && root.windowRadius > 0 ? 8 : 0
                            color: mouseArea.containsMouse
                                ? (windowControlButton.isClose ? "#e81123" : ThemeManager.surfaceHover)
                                : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: windowControlButton.icon
                                font.pixelSize: windowControlButton.isClose ? 18 : 12
                                color: mouseArea.containsMouse && windowControlButton.isClose
                                    ? "white"
                                    : ThemeManager.textSecondary

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: windowControlButton.triggerAction()
                            }

                            function triggerAction() {
                                if (windowControlButton.index === 0) {
                                    root.showMinimized()
                                } else if (windowControlButton.index === 1) {
                                    if (root.visibility === Window.Maximized) {
                                        root.showNormal()
                                    } else {
                                        root.showMaximized()
                                    }
                                } else {
                                    Qt.quit()
                                }
                            }
                        }
                    }
                }
            }

            // 主内容 - 根据登录状态显示不同页面
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: root.isLoggedIn ? chatContentComponent : loginPageComponent
            }

            Component {
                id: loginPageComponent
                LoginPage {
                    onCreateAccountRequested: {
                        // TODO: 实现创建账户逻辑
                        console.log("Create account requested")
                    }
                }
            }

            // 监听登录结果
            Connections {
                target: login
                function onLoginSucceeded() {
                    root.isLoggedIn = true
                }
            }

            Component {
                id: chatContentComponent
                RowLayout {
                    spacing: 0

        // Sidebar
        Sidebar {
            id: sidebar
            Layout.preferredWidth: root.isMobile ? root.width : (root.isCompact ? 280 : 320)
            Layout.fillHeight: true
            visible: !root.isMobile || root.currentConversationId === ""
            currentConversationId: root.currentConversationId

            onConversationSelected: (id) => {
                root.currentConversationId = id
            }

            onSettingsClicked: {
                settingsDrawer.open()
            }
        }

        // Divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: ThemeManager.divider
            visible: !root.isMobile && sidebar.visible

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }

        // Main Content
        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.isMobile || root.currentConversationId !== ""

            Loader {
                id: contentLoader
                anchors.fill: parent

                sourceComponent: root.currentConversationId === "" ? emptyStateComponent : conversationViewComponent
            }

            Component {
                id: emptyStateComponent
                EmptyState {}
            }

            Component {
                id: conversationViewComponent
                ConversationView {
                    conversationId: root.currentConversationId
                    onBackClicked: {
                        root.currentConversationId = ""
                    }
                }
            }

            // Page transition animation
            opacity: 1
            scale: 1

            states: [
                State {
                    name: "changing"
                    PropertyChanges {
                        contentContainer.opacity: 0
                        contentContainer.scale: 0.95
                    }
                }
            ]

            transitions: [
                Transition {
                    to: ""
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            ]
        }
        }
            }
        }
    }

    // Settings Drawer
    Drawer {
        id: settingsDrawer
        width: Math.min(400, root.width * 0.85)
        height: root.height
        edge: Qt.RightEdge

        background: Rectangle {
            color: ThemeManager.background

            Behavior on color {
                ColorAnimation { duration: ThemeManager.transitionDuration }
            }
        }

        SettingsPage {
            anchors.fill: parent
            onClose: settingsDrawer.close()
        }

        enter: Transition {
            NumberAnimation {
                property: "position"
                from: 0
                to: 1
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "position"
                from: 1
                to: 0
                duration: 200
                easing.type: Easing.InCubic
            }
        }
    }

    // Android返回键处理
    onClosing: (close) => {
        if (root.isAndroid) {
            if (settingsDrawer.opened) {
                close.accepted = false
                settingsDrawer.close()
            } else if (root.currentConversationId !== "") {
                close.accepted = false
                root.currentConversationId = ""
            }
        }
    }
}
