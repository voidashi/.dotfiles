-- =====================================================================
--  AUTOSTART
-- =====================================================================
-- Inicialização automática de processos necessários, como notificações e status bars
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- uwsm, when the session was started through it, needs this to export
    -- WAYLAND_DISPLAY into the systemd user manager and report the compositor
    -- unit as started; without it the unit sits in activating and times out.
    -- /usr/share/wayland-sessions/hyprland-uwsm.desktop is what starts a session
    -- that way, and it ships with Hyprland rather than with uwsm.
    --
    -- Unconditional on purpose. Measured in a session started directly by the
    -- greeter: it prints one line to stderr and exits 0. Keep it in step with
    -- the same line in sway/config. See docs/TODO.md for why uwsm is involved.
    hl.exec_cmd("uwsm finalize")

    hl.exec_cmd("rfkill block bluetooth")

    hl.exec_cmd("nm-applet")
    -- hl.exec_cmd("waybar")
    -- Absolute paths: with a relative one this depended on the cwd Hyprland was
    -- started with, and the bar did not come up depending on how you logged in.
    -- It is about $HOME-relative paths, not about the clone directory, which the
    -- line below no longer names.
    hl.exec_cmd("waybar -c $HOME/.config/waybar/hyprland.jsonc -s $HOME/.config/waybar/style.css")
    -- In order: the wallpapers in rotation, then the full collection, then the
    -- repo's own sample, which is what makes a fresh install work. The script and
    -- the sample are both reached through links backup-configs.sh install creates,
    -- so neither names where the repo was cloned.
    --
    -- $HOME/.local/bin is spelled out rather than relied on through PATH. A session
    -- started by a display manager does not read a shell profile, and that profile
    -- is the only thing putting ~/.local/bin on PATH here, so under greetd this
    -- line resolved to nothing and swaybg ran with an empty -i. See
    -- docs/TURNING-POINTS.md; the path is fixed and names no clone directory.
    -- Bare name form, which works only in a session that carries ~/.local/bin on
    -- PATH, meaning one started through uwsm or from a shell:
    --   swaybg -m fill -i "$(select-random-wallpaper.sh ...)"
    hl.exec_cmd(
        "swaybg -m fill -i \"$($HOME/.local/bin/select-random-wallpaper.sh "
            .. "$HOME/Pictures/Current_wallpapers "
            .. "$HOME/Pictures/Wallpapers "
            .. "$HOME/.local/share/wallpapers/dotfiles)\""
    )

    -- Era "kill mako & swaync", com dois defeitos numa linha: kill so aceita
    -- PID e nunca aceitou nome de processo, entao aquilo so gerava erro; e o
    -- mako nem esta instalado nesta maquina, entao nao havia o que matar.
    hl.exec_cmd("swaync")

    -- Clipboard history, cleared at every session start. wl-paste --watch is the
    -- only thing that feeds cliphist, so without this line the SUPER+SHIFT+V bind
    -- opens a permanently empty menu. The wipe runs first and in the same shell so
    -- the order cannot invert. Without it the history is kept forever: cliphist's
    -- db is a plain file under ~/.cache and it had survived four reboots.
    -- Keep in step with the same line in sway/config.
    hl.exec_cmd("sh -c 'cliphist wipe; exec wl-paste --watch cliphist store'")

    -- Idle: trava, apaga a tela e suspende, conforme hypr/hypridle.conf.
    -- Sob systemd-cat porque o hypridle só escreve em stdout e nada capturava
    -- isso: uma madrugada inteira de bloqueios teve de ser reconstruída a
    -- partir de efeitos colaterais no journal, porque não havia registro de um
    -- único deles. Com a tag, "journalctl -t hypridle" mostra cada timeout com
    -- hora. Ver docs/MAINTENANCE.md.
    hl.exec_cmd("systemd-cat -t hypridle hypridle")
end)
