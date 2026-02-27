import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Qt.labs.synchronizer
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: overviewScope
    property bool dontAutoCancelSearch: false

    PanelWindow {
        id: panelWindow
        property string searchingText: ""
        readonly property HyprlandMonitor monitor: Hyprland.monitorFor(panelWindow.screen)
        property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)
        visible: true
        screen: Hyprland.focusedMonitor?.screen ?? Quickshell.primaryScreen

        WlrLayershell.namespace: "quickshell:overview"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: GlobalStates.overviewOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        mask: Region {
            item: GlobalStates.overviewOpen ? columnLayout : null
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Connections {
            target: GlobalStates
            function onOverviewOpenChanged() {
                if (!GlobalStates.overviewOpen) {
                    searchWidget.disableExpandAnimation()
                    overviewScope.dontAutoCancelSearch = false
                    GlobalFocusGrab.dismiss()
                } else {
                    if (!overviewScope.dontAutoCancelSearch) {
                        searchWidget.cancelSearch()
                    }
                    GlobalFocusGrab.addDismissable(panelWindow)
                }
            }
        }

        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                GlobalStates.overviewOpen = false
            }
        }

        implicitWidth: columnLayout.implicitWidth
        implicitHeight: columnLayout.implicitHeight

        function setSearchingText(text) {
            searchWidget.setSearchingText(text)
            searchWidget.focusFirstItem()
        }

        Column {
            id: columnLayout
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            spacing: -8

            scale: GlobalStates.overviewOpen ? 1.0 : 0.95
            opacity: GlobalStates.overviewOpen ? 1.0 : 0.0
            enabled: GlobalStates.overviewOpen

            Behavior on scale {
                enabled: GlobalStates.overviewOpen || !overviewLoader.item
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                enabled: GlobalStates.overviewOpen || !overviewLoader.item
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    GlobalStates.overviewOpen = false
                } else if (event.key === Qt.Key_Left) {
                    if (!panelWindow.searchingText)
                        Hyprland.dispatch("workspace r-1")
                } else if (event.key === Qt.Key_Right) {
                    if (!panelWindow.searchingText)
                        Hyprland.dispatch("workspace r+1")
                }
            }

            SearchWidget {
                id: searchWidget
                anchors.horizontalCenter: parent.horizontalCenter
                Synchronizer on searchingText {
                    property alias source: panelWindow.searchingText
                }
            }

            Loader {
                id: overviewLoader
                anchors.horizontalCenter: parent.horizontalCenter
                active: GlobalStates.overviewOpen && (Config?.options.overview.enable ?? true)
                asynchronous: true
                visible: panelWindow.searchingText === ""

                sourceComponent: OverviewWidget {
                    screen: panelWindow.screen
                }

                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
                Behavior on scale {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    function toggleClipboard() {
        if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
            GlobalStates.overviewOpen = false
            return
        }
        overviewScope.dontAutoCancelSearch = true
        panelWindow.setSearchingText(Config.options.search.prefix.clipboard)
        GlobalStates.overviewOpen = true
    }

    function toggleEmojis() {
        if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
            GlobalStates.overviewOpen = false
            return
        }
        overviewScope.dontAutoCancelSearch = true
        panelWindow.setSearchingText(Config.options.search.prefix.emojis)
        GlobalStates.overviewOpen = true
    }

    IpcHandler {
        target: "search"

        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
        function workspacesToggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
        function close() {
            GlobalStates.overviewOpen = false
        }
        function open() {
            GlobalStates.overviewOpen = true
        }
        function toggleReleaseInterrupt() {
            GlobalStates.superReleaseMightTrigger = false
        }
        function clipboardToggle() {
            overviewScope.toggleClipboard()
        }
    }

    GlobalShortcut {
        name: "searchToggle"
        onPressed: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
    }

    GlobalShortcut {
        name: "overviewWorkspacesClose"
        onPressed: GlobalStates.overviewOpen = false
    }

    GlobalShortcut {
        name: "overviewWorkspacesToggle"
        onPressed: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
    }

    GlobalShortcut {
        name: "searchToggleRelease"
        onPressed: GlobalStates.superReleaseMightTrigger = true
        onReleased: {
            if (!GlobalStates.superReleaseMightTrigger) return
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
    }

    GlobalShortcut {
        name: "searchToggleReleaseInterrupt"
        onPressed: GlobalStates.superReleaseMightTrigger = false
    }

    GlobalShortcut {
        name: "overviewClipboardToggle"
        onPressed: overviewScope.toggleClipboard()
    }

    GlobalShortcut {
        name: "overviewEmojiToggle"
        onPressed: overviewScope.toggleEmojis()
    }
}
