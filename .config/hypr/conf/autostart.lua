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
    hl.exec_cmd("waybar -c $HOME/.config/waybar/hyprland.jsonc -s $HOME/.config/waybar/style.css")
    -- Ordem: os wallpapers em rotação, depois a coleção completa, depois o
    -- wallpaper de exemplo do próprio repo (para uma instalação nova).
    hl.exec_cmd(
        "swaybg -m fill -i \"$($HOME/.dotfiles/scripts/wm/select-random-wallpaper.sh "
            .. "$HOME/Pictures/Current_wallpapers "
            .. "$HOME/Pictures/Wallpapers "
            .. "$HOME/.dotfiles/wallpapers)\""
    )

    -- Era "kill mako & swaync", com dois defeitos numa linha: kill so aceita
    -- PID e nunca aceitou nome de processo, entao aquilo so gerava erro; e o
    -- mako nem esta instalado nesta maquina, entao nao havia o que matar.
    hl.exec_cmd("swaync")
end)
