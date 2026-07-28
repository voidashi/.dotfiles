-- =====================================================================
--  AUTOSTART
-- =====================================================================
-- Inicialização automática de processos necessários, como notificações e status bars
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("rfkill block bluetooth")

    hl.exec_cmd("nm-applet")
    -- hl.exec_cmd("waybar")
    -- Caminhos absolutos: com caminho relativo isto dependia do cwd com que
    -- o Hyprland foi iniciado, e a barra não subia dependendo de como logava.
    hl.exec_cmd("waybar -c $HOME/.config/waybar/fixed/config.jsonc -s $HOME/.config/waybar/fixed/style.css")
    hl.exec_cmd("swaybg -m fill -i \"$(bash $HOME/scripts/select_random_wallpaper.sh $HOME/Pictures/Wallpapers)\"")

    hl.exec_cmd("kill mako & swaync")
end)
