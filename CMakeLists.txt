cmake_minimum_required(VERSION 3.16)

project(ModernChat VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 QuickEffects)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(ModernChat
    main.cpp
    src/Logic/Login.cpp
    src/Logic/RoomUtils.cpp
    src/Utils/LogHandler.cpp
)

set_source_files_properties(qml/theme/ThemeManager.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)
set_source_files_properties(qml/models/MockData.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(ModernChat
    URI ModernChat
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        # Theme
        qml/theme/ThemeManager.qml
        # Components
        qml/components/Avatar.qml
        qml/components/Badge.qml
        qml/components/IconButton.qml
        qml/components/SearchField.qml
        qml/components/MessageBubble.qml
        qml/components/MessageInput.qml
        qml/components/TypingIndicator.qml
        qml/components/ThemeToggle.qml
        # Pages
        qml/pages/ConversationView.qml
        qml/pages/SettingsPage.qml
        qml/pages/EmptyState.qml
        # Sidebar
        qml/sidebar/Sidebar.qml
        qml/sidebar/ConversationList.qml
        qml/sidebar/ConversationDelegate.qml
        qml/sidebar/SidebarHeader.qml
        # Models
        qml/models/ConversationModel.qml
        qml/models/MessageModel.qml
        qml/models/MockData.qml
    RESOURCES
        resources/icons/send.svg
        resources/icons/settings.svg
        resources/icons/search.svg
        resources/icons/moon.svg
        resources/icons/sun.svg
        resources/icons/attachment.svg
        resources/icons/emoji.svg
        resources/icons/check.svg
        resources/icons/check-double.svg
        resources/icons/arrow-left.svg
        resources/icons/user.svg
        resources/icons/close.svg
        resources/icons/menu.svg
)

target_link_libraries(ModernChat PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickEffects
)

target_include_directories(ModernChat PRIVATE
    include
)

if(WIN32)
    set_target_properties(ModernChat PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()
