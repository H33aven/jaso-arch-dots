--require("modules.variables")
require("modules.colors")
require("modules.monitors")
require("modules.execs")
require("modules.general")
require("modules.binds")
require("modules.rules")
require("modules.env")
--exec-once = swaybg -i /home/jaso/Wallpapers/girls.jpg -m fill &
--exec-once = hyprctl setcursor Bibata-Modern-Classic 20
--exec-once = gentoo-pipewire-launcher restart

--mtc ~/Wallpapers/girls.jpg --source-color-index 0
--sudo emerge --ask app-misc/illogical-impulse-{audio,backlight,basic,bibata-modern-classic-bin,kde,microtex-git,portal,python,screencapture,toolkit,widgets} --autounmask
