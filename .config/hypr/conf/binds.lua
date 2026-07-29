-- =====================================================================
--  ATALHOS (BINDINGS)
-- =====================================================================
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- https://wiki.hypr.land/Configuring/Basics/Dispatchers/
-- Depende de conf.d/programs.lua (terminal, fileManager, menu), que é
-- carregado antes deste arquivo em hyprland.lua.
local mainMod = "SUPER"

-- Atalhos principais
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill()) -- fecha à força (SIGKILL), para apps travados
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(terminal .. " -e " .. terminalFileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))

-- Alternar layout e pseudotiling
-- hl.bind(mainMod .. " + L", hl.dsp.layout("changelayout dwindle"))
-- hl.bind(mainMod .. " + T", hl.dsp.layout("changelayout master"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Agrupar/desagrupar a janela ativa em abas (tabbed group)
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())

-- Modo de redimensionar com as setas (ESC para sair)
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x = 10, y = 0, relative = true }),  { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x = 0, y = 10, relative = true }),  { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Movimentação e navegação
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mover a janela ativa com SHIFT + setas.
-- swap troca a janela de lugar com a vizinha e preserva a geometria da árvore
-- do dwindle, então o resultado é o que se vê acontecer. move reinsere a janela
-- na árvore de splits, o que recalcula proporções e faz as janelas mudarem de
-- tamanho ao serem movidas; em compensação alcança monitores vizinhos quando
-- não há janela na direção. Para trocar de comportamento, troque as linhas.
-- hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
-- hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
-- hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
-- hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

-- Alternar workspaces com mainMod + [0-9]
-- Enviar janela ativa para outro workspace com mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 mapeia para a tecla 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Alternar workspaces com scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Movimentar/redimensionar janelas com mainMod + LMB/RMB
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Teclas multimídia para volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),  { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),      { locked = true })

-- Teclas multimídia para brilho
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 2%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 2%-"), { locked = true, repeating = true })

-- Screenshots
-- Screenshot de uma janela
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
-- Screenshot de um monitor
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
-- Screenshot de uma região
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))

-- Clipboard
-- SUPER + V ja e float, entao o historico fica no SHIFT do mesmo dedo. O
-- pipeline inteiro esta em scripts/wm/clipboard-picker.sh, e nao aqui, porque o
-- Sway usa exatamente o mesmo e duas copias divergem.
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("$HOME/.dotfiles/scripts/wm/clipboard-picker.sh"))

-- Dispara quando a tampa (lid) é alternada
-- A aparência da tela de bloqueio vem de ~/.config/swaylock/config, que já é
-- versionado neste repo. O antigo lock.sh passava as mesmas opções por linha
-- de comando e sobrescrevia esse arquivo com um tema diferente.
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("swaylock -f"), { locked = true })
-- Dispara quando a tampa está fechando
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, disable"'), { locked = true })
-- Dispara quando a tampa está abrindo
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, 1920x1080, 0x0, 1"'), { locked = true })
