-- =====================================================================
--  AUTOSTART
-- =====================================================================
-- Inicialização automática de processos necessários, como notificações e status bars
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("rfkill block bluetooth")

    hl.exec_cmd("nm-applet")
    -- hl.exec_cmd("waybar")
    hl.exec_cmd("waybar -c .config/waybar/fixed/config.jsonc -s .config/waybar/fixed/style.css")
    hl.exec_cmd("swaybg -m fill -i \"$(bash $HOME/scripts/select_random_wallpaper.sh $HOME/Pictures/Wallpapers)\"")

    hl.exec_cmd("kill mako & swaync")
end)
