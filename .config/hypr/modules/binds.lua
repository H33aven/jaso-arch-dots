-- modules/binds.lua
require("modules.lib")

local mod = "SUPER"
local term = "kitty"
local browser = "app.zen_browser.zen"
local code = "code"
local music = "~/Tests/kute/kute-releases/Kute-1.9.1.AppImage"
local files = "dolphin"
local settingsApp = "qs -p /home/jaso/.config/quickshell/end4-pC/modules/ii/settings/Settings.qml"
-- binds
local qsScripts = "$HOME/.config/quickshell/$qsConfig/scripts"
local hyprScripts = "$HOME/.config/hypr/hyprland/scripts"
local qsIpcCall = "qs -c $qsConfig ipc call"
local qsIsAlive = qsIpcCall .. " TEST_ALIVE"
-- apps
hl.bind(mod .. " + T", hl.dsp.exec_cmd(term))
hl.bind(mod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + C", hl.dsp.exec_cmd(code))
--hl.bind(mod .. " + SUPER_L", hl.dsp.exec_cmd("killall rofi || rofi -show drun"))
hl.bind("SUPER + SUPER_L", hl.dsp.global("quickshell:searchToggleRelease"), { description = "Shell: Toggle search" })
hl.bind("SUPER + SUPER_R", hl.dsp.global("quickshell:searchToggleRelease"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(files))
hl.bind(mod .. " + Y", hl.dsp.exec_cmd(music))

--hl.bind(mod .. " + I", hl.dsp.exec_cmd(settingsApp))
hl.bind(mod .. " + I", hl.dsp.global("quickshell:settingsToggle"), { description = "Shell: Toggle settings" })

-- scripts
--hl.bind(mod .. " + CTRL + T", hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/rofi-wallpaper.sh"))
--hl.bind("SUPER + V", hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/rofi-clipboard.sh"))
--hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { description = "Microphone mute/unmute" })

-- windows
hl.bind(mod .. " + N", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pin())
hl.bind(mod .. " + R", hl.dsp.window.float({ action = "toggle" }))


hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + Z", hl.dsp.window.drag())
hl.bind(mod .. " + X", hl.dsp.window.resize())

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + ALT + Q", hl.dsp.exec_cmd("hyprctl kill"), { description = "Window: Forcefully zap a window" })

hl.bind(mod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }), { repeating = true })
hl.bind(mod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind(mod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }), { repeating = true })

-- workspaces
for i = 1, 10 do
    local keycode = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
    hl.bind(mod .. " + SHIFT + code:" .. keycode[i],
        hl.dsp.window.move({ workspace = tostring(i), follow = true }))
end

for i = 1, 10 do
    local keycode = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
    hl.bind(mod .. " + ALT + code:" .. keycode[i],
        hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

local keycodes = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
for i, code in ipairs(keycodes) do
    hl.bind(mod .. " + code:" .. code, function()
        hl.dispatch(hl.dsp.focus({ workspace = tostring(i) }))
    end, { description = "Workspace " .. i })
end



--# OCR
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:regionOcr"),
    { description = "Utilities: Character recognition >> clipboard" })
hl.bind("SUPER + SHIFT + X", hl.dsp.global("quickshell:screenTranslate"),
    { description = "Utilities: Translate screen content" })

-- scratchpad
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("special"))
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }))


-- quickshell
-- sidebars
hl.bind("SUPER + A", hl.dsp.global("quickshell:sidebarLeftToggle"), { description = "Shell: Toggle left sidebar" })
hl.bind("SUPER + D", hl.dsp.global("quickshell:sidebarRightToggle"), { description = "Shell: Toggle right sidebar" })

-- huynya kakaya to
hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"),
    { ignore_mods = true, transparent = true, release = true })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"),
    { ignore_mods = true, transparent = true, release = true })



-- da
hl.bind("SUPER + V", hl.dsp.global("quickshell:overviewClipboardToggle"))
hl.bind("SUPER + Period", hl.dsp.global("quickshell:overviewEmojiToggle"))
hl.bind("SUPER + J", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })
hl.bind("SUPER + G", hl.dsp.global("quickshell:overlayToggle"), { description = "Shell: Toggle widget overlay" })
hl.bind("SUPER + Slash", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })
hl.bind("SUPER + K", hl.dsp.global("quickshell:oskToggle"), { description = "Shell: Toggle on-screen keyboard" })
hl.bind("SUPER + M", hl.dsp.global("quickshell:mediaControlsToggle"), { description = "Shell: Toggle media controls" })



-- wallpaper selector
hl.bind("CTRL + SUPER + T", hl.dsp.global("quickshell:wallpaperSelectorToggle"),
    { description = "Shell: Change wallpaper" })

-- screenshot maker
hl.bind("SUPER + SHIFT + S", hl.dsp.global("quickshell:regionScreenshot"), { description = "Utilities: Screen snip" })
--hl.bind("SUPER + SHIFT + S",
--    hl.dsp.exec_cmd(qsIsAlive .. " || pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent"))

-- full screenshot
local grimhyprctl = "grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\""
hl.bind("Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"),
    { locked = true, description = "Utilities: Screenshot >> clipboard" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "mkdir -p $(xdg-user-dir PICTURES)/Screenshots && " ..
    grimhyprctl .. " $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"
), { locked = true, non_consuming = true, description = "Utilities: Screenshot >> clipboard & file" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"), { locked = true, non_consuming = true })

-- color picker
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"),
    { description = "Utilities: Pick color #RRGGBB >> clipboard" })

-- record screen
hl.bind("SUPER + SHIFT + R", hl.dsp.global("quickshell:regionRecord"),
    { locked = true, description = "Utilities: Record region (no sound)" })
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"), { locked = true })

-- zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind("SUPER + Minus", function() zoomfunction(-0.3) end, { repeating = true, description = "Screen: Zoom out" })
hl.bind("SUPER + Equal", function() zoomfunction(0.3) end, { repeating = true, description = "Screen: Zoom in" })

-- split ratio
hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true })

-- sleep

hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Session: Lock" })
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"),
    { locked = true, description = "Session: Sleep" })







hl.bind("SUPER + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"), { description = "Shell: Toggle overview" })
hl.bind("SUPER + ALT + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"))
hl.bind("CTRL + ALT + Delete", hl.dsp.global("quickshell:sessionToggle"), { description = "Shell: Toggle session menu" })
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(qsIsAlive .. " || pkill wlogout || wlogout -p layer-shell"))
hl.bind("SHIFT + SUPER + ALT + Slash", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/$qsConfig/welcome.qml"))