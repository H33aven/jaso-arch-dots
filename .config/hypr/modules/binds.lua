-- modules/binds.lua
require("modules.lib")

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
hl.bind(mod .. " + T", hl.dsp.exec_cmd(term))
hl.bind(mod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + C", hl.dsp.exec_cmd(code))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(files))
hl.bind(mod .. " + Y", hl.dsp.exec_cmd(music))

-- quickshell global shortcuts
hl.bind("SUPER + SUPER_L", hl.dsp.global("quickshell:searchToggleRelease"))
hl.bind("SUPER + SUPER_R", hl.dsp.global("quickshell:searchToggleRelease"))
hl.bind(mod .. " + I", hl.dsp.global("quickshell:settingsToggle"))
hl.bind(mod .. " + A", hl.dsp.global("quickshell:sidebarLeftToggle"))
hl.bind(mod .. " + D", hl.dsp.global("quickshell:sidebarRightToggle"))
hl.bind(mod .. " + ALT + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"))
hl.bind(mod .. " + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"))
hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true, release = true })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true, release = true })
hl.bind(mod .. " + V", hl.dsp.global("quickshell:overviewClipboardToggle"))
hl.bind(mod .. " + Period", hl.dsp.global("quickshell:overviewEmojiToggle"))
hl.bind(mod .. " + J", hl.dsp.global("quickshell:barToggle"))
hl.bind(mod .. " + G", hl.dsp.global("quickshell:overlayToggle"))
hl.bind(mod .. " + Slash", hl.dsp.global("quickshell:cheatsheetToggle"))
hl.bind(mod .. " + K", hl.dsp.global("quickshell:oskToggle"))
hl.bind(mod .. " + M", hl.dsp.global("quickshell:mediaControlsToggle"))
hl.bind(modCtrl .. " + " .. mod .. " + T", hl.dsp.global("quickshell:wallpaperSelectorToggle"))
hl.bind(modCtrl .. " + " .. modAlt .. " + Delete", hl.dsp.global("quickshell:sessionToggle"))
hl.bind(modCtrl .. " + " .. modAlt .. " + Delete", hl.dsp.exec_cmd(qsIsAlive .. " || pkill wlogout || wlogout -p layer-shell"))
hl.bind("SHIFT + " .. mod .. " + " .. modAlt .. " + Slash", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/$qsConfig/welcome.qml"))

-- window management
hl.bind(mod .. " + N", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pin())
hl.bind(mod .. " + R", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + Z", hl.dsp.window.drag())
hl.bind(mod .. " + X", hl.dsp.window.resize())
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + ALT + Q", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }), { repeating = true })
hl.bind(mod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind(mod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }), { repeating = true })

-- workspaces
for i, code in ipairs(keycodes) do
    hl.bind(mod .. " + code:" .. code, function()
        hl.dispatch(hl.dsp.focus({ workspace = tostring(i) }))
    end)
end
for i, code in ipairs(keycodes) do
    hl.bind(mod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = tostring(i), follow = true }))
end
for i, code in ipairs(keycodes) do
    hl.bind(mod .. " + ALT + code:" .. code, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

-- scratchpad
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("special"))
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }))

-- utilities
hl.bind("XF86Calculator", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"))
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:regionOcr"))
hl.bind("SUPER + SHIFT + X", hl.dsp.global("quickshell:screenTranslate"))
hl.bind("SUPER + SHIFT + S", hl.dsp.global("quickshell:regionScreenshot"))
local grimhyprctl = "grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\""
hl.bind("Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"), { locked = true })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "mkdir -p $(xdg-user-dir PICTURES)/Screenshots && " ..
    grimhyprctl .. " $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"
), { locked = true, non_consuming = true })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"), { locked = true, non_consuming = true })
hl.bind("SUPER + SHIFT + R", hl.dsp.global("quickshell:regionRecord"), { locked = true })
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"), { locked = true })
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    local newZoom = math.max(1.0, math.min(3.0, zoomvalue + value))
    hl.config({ cursor = { zoom_factor = newZoom } })
end
hl.bind("SUPER + Minus", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind("SUPER + Equal", function() zoomfunction(0.3) end, { repeating = true })

hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true })

hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"), { locked = true })