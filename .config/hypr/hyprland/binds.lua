-- modules/binds.lua
require("hyprland.lib")

local mod = "SUPER"
local modShift = mod .. " + SHIFT"
local modCtrl = "CTRL"
local modAlt = "ALT"

local term = "kitty"
local browser = "app.zen_browser.zen"
local code = "code"
local music = "~/Tests/kute/kute-releases/Kute-1.9.1.AppImage"
local files = "dolphin"
local settingsApp = "qs -p /home/jaso/.config/quickshell/end4-pC/modules/ii/settings/Settings.qml"

local qsScripts = "$HOME/.config/quickshell/$qsConfig/scripts"
local hyprScripts = "$HOME/.config/hypr/modules/scripts"
local qsIpcCall = "qs -c $qsConfig ipc call"
local qsIsAlive = qsIpcCall .. " TEST_ALIVE"

local keycodes = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19}

-- apps
hl.bind(mod .. " + T", hl.dsp.exec_cmd(term), { description = "App: Terminal" })
hl.bind(mod .. " + W", hl.dsp.exec_cmd(browser), { description = "App: Browser" })
hl.bind(mod .. " + C", hl.dsp.exec_cmd(code), { description = "App: Code editor" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd(files), { description = "App: File manager" })
hl.bind(mod .. " + Y", hl.dsp.exec_cmd(music), { description = "App: Music player" })

-- quickshell global shortcuts
hl.bind("SUPER + SUPER_L", hl.dsp.global("quickshell:searchToggleRelease"), { description = "Shell: Toggle search" })
hl.bind("SUPER + SUPER_R", hl.dsp.global("quickshell:searchToggleRelease"), { description = "Shell: Toggle search" })
hl.bind(mod .. " + I", hl.dsp.global("quickshell:settingsToggle"), { description = "Shell: Toggle settings" })
hl.bind(mod .. " + A", hl.dsp.global("quickshell:sidebarLeftToggle"), { description = "Shell: Toggle left sidebar" })
hl.bind(mod .. " + D", hl.dsp.global("quickshell:sidebarRightToggle"), { description = "Shell: Toggle right sidebar" })
hl.bind(mod .. " + ALT + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"), { description = "Shell: Toggle left sidebar (detached)" })
hl.bind(mod .. " + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"), { description = "Shell: Toggle overview" })
hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true, release = true, description = "Shell: Show workspace number" })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true, release = true, description = "Shell: Show workspace number" })
hl.bind(mod .. " + V", hl.dsp.global("quickshell:overviewClipboardToggle"), { description = "Shell: Toggle clipboard history" })
hl.bind(mod .. " + Period", hl.dsp.global("quickshell:overviewEmojiToggle"), { description = "Shell: Toggle emoji picker" })
hl.bind(mod .. " + J", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })
hl.bind(mod .. " + G", hl.dsp.global("quickshell:overlayToggle"), { description = "Shell: Toggle widget overlay" })
hl.bind(mod .. " + Slash", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })
hl.bind(mod .. " + K", hl.dsp.global("quickshell:oskToggle"), { description = "Shell: Toggle on-screen keyboard" })
hl.bind(mod .. " + M", hl.dsp.global("quickshell:mediaControlsToggle"), { description = "Shell: Toggle media controls" })
hl.bind(modCtrl .. " + " .. mod .. " + T", hl.dsp.global("quickshell:wallpaperSelectorToggle"), { description = "Shell: Change wallpaper" })
hl.bind(modCtrl .. " + " .. modAlt .. " + Delete", hl.dsp.global("quickshell:sessionToggle"), { description = "Shell: Toggle session menu" })
hl.bind(modCtrl .. " + " .. modAlt .. " + Delete", hl.dsp.exec_cmd(qsIsAlive .. " || pkill wlogout || wlogout -p layer-shell"), { description = "Shell: Toggle session menu" })
hl.bind("SHIFT + " .. mod .. " + " .. modAlt .. " + Slash", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/$qsConfig/welcome.qml"), { description = "Shell: Show welcome" })

-- window management
hl.bind(mod .. " + N", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Toggle maximize" })
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Window: Toggle fullscreen" })
hl.bind(mod .. " + P", hl.dsp.window.pin(), { description = "Window: Pin window" })
hl.bind(mod .. " + R", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Toggle float" })
hl.bind(mod .. " + Z", hl.dsp.window.drag(), { description = "Window: Drag (move)" })
hl.bind(mod .. " + X", hl.dsp.window.resize(), { description = "Window: Resize" })
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Drag (move)" })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true, description = "Window: Drag (move)" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })
hl.bind(mod .. " + Q", hl.dsp.window.close(), { description = "Window: Close" })
hl.bind("SUPER + SHIFT + ALT + Q", hl.dsp.exec_cmd("hyprctl kill"), { description = "Window: Forcefully kill window" })
hl.bind(mod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }), { repeating = true, description = "Window: Move left" })
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }), { repeating = true, description = "Window: Move right" })
hl.bind(mod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }), { repeating = true, description = "Window: Move up" })
hl.bind(mod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }), { repeating = true, description = "Window: Move down" })

-- workspaces
for i, code in ipairs(keycodes) do
    hl.bind(mod .. " + code:" .. code, function()
        hl.dispatch(hl.dsp.focus({ workspace = tostring(i) }))
    end, { description = "Workspace: Focus " .. i })
end
for i, code in ipairs(keycodes) do
    hl.bind(mod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = tostring(i), follow = true }), { description = "Window: Move to workspace " .. i })
end
for i, code in ipairs(keycodes) do
    hl.bind(mod .. " + ALT + code:" .. code, hl.dsp.window.move({ workspace = tostring(i), follow = false }), { description = "Window: Send to workspace " .. i .. " (stay)" })
end

-- scratchpad
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("special"), { description = "Workspace: Toggle scratchpad" })
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }), { description = "Window: Send to scratchpad" })

-- utilities
hl.bind("XF86Calculator", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { description = "Microphone: Toggle mute" })
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:regionOcr"), { description = "Utilities: OCR region >> clipboard" })
hl.bind("SUPER + SHIFT + X", hl.dsp.global("quickshell:screenTranslate"), { description = "Utilities: Translate screen content" })
hl.bind("SUPER + SHIFT + S", hl.dsp.global("quickshell:regionScreenshot"), { description = "Utilities: Screen snip" })
local grimhyprctl = "grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\""
hl.bind("Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"), { locked = true, description = "Utilities: Full screenshot >> clipboard" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "mkdir -p $(xdg-user-dir PICTURES)/Screenshots && " ..
    grimhyprctl .. " $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"
), { locked = true, non_consuming = true, description = "Utilities: Full screenshot >> clipboard & file" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"), { locked = true, non_consuming = true, description = "Utilities: Full screenshot >> clipboard" })
hl.bind("SUPER + SHIFT + R", hl.dsp.global("quickshell:regionRecord"), { locked = true, description = "Utilities: Record region (no sound)" })
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"), { locked = true, description = "Utilities: Record region (no sound)" })
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Utilities: Pick color >> clipboard" })

local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    local newZoom = math.max(1.0, math.min(3.0, zoomvalue + value))
    hl.config({ cursor = { zoom_factor = newZoom } })
end
hl.bind("SUPER + Minus", function() zoomfunction(-0.3) end, { repeating = true, description = "Screen: Zoom out" })
hl.bind("SUPER + Equal", function() zoomfunction(0.3) end, { repeating = true, description = "Screen: Zoom in" })

hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true, description = "Layout: Decrease split ratio" })
hl.bind("SUPER + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true, description = "Layout: Increase split ratio" })

hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Session: Lock" })
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"), { locked = true, description = "Session: Sleep" })