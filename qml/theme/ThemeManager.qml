pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool isDark: false

    readonly property int transitionDuration: 300

    // Background colors
    readonly property color background: isDark ? "#0f0f1a" : "#ffffff"
    readonly property color backgroundSecondary: isDark ? "#1a1a2e" : "#f5f7fb"
    readonly property color backgroundTertiary: isDark ? "#252545" : "#eef2f7"

    // Surface colors
    readonly property color surface: isDark ? "#1f1f35" : "#ffffff"
    readonly property color surfaceHover: isDark ? "#2a2a4a" : "#f0f4f8"
    readonly property color surfaceActive: isDark ? "#35355f" : "#e3e9f0"

    // Text colors
    readonly property color textPrimary: isDark ? "#f0f0f5" : "#1a1a2e"
    readonly property color textSecondary: isDark ? "#a0a0b0" : "#6b7280"
    readonly property color textMuted: isDark ? "#6b6b7b" : "#9ca3af"

    // Accent color
    readonly property color accent: "#6366f1"
    readonly property color accentHover: "#818cf8"
    readonly property color accentLight: isDark ? "#312e81" : "#e0e7ff"

    // Message bubbles
    readonly property color bubbleSent: accent
    readonly property color bubbleSentText: "#ffffff"
    readonly property color bubbleReceived: isDark ? "#2a2a4a" : "#f3f4f6"
    readonly property color bubbleReceivedText: textPrimary

    // Status colors
    readonly property color online: "#22c55e"
    readonly property color away: "#f59e0b"
    readonly property color offline: "#6b7280"

    // Border and divider
    readonly property color border: isDark ? "#3a3a5a" : "#e5e7eb"
    readonly property color divider: isDark ? "#252545" : "#f3f4f6"

    // Shadow
    readonly property color shadow: isDark ? "#000000cc" : "#0000001a"

    function toggle() {
        isDark = !isDark
    }

    function setTheme(dark) {
        isDark = dark
    }
}
