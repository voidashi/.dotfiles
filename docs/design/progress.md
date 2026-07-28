# Progresso do retema Voidashi no rice

Log de execução do plano aprovado em 2026-07-28 para aplicar o design system Voidashi
(`system.md` + `rice.md` + `aesthetic-direction.md`) ao rice Linux. Existe porque a
conversa que gerou esse trabalho já perdeu contexto uma vez (compactação) — este arquivo é
a fonte de continuidade entre sessões, não a memória do assistente.

Plano completo original: seis commits, nesta ordem. Cada seção abaixo é atualizada quando
o commit correspondente é feito.

---

## 1 — Infra: `scripts/theme/palette.json` + `scripts/theme/generate_theme.py`

**Status:** concluído

Fonte única de verdade em JSON (tokens de `system.md` §2 + ANSI-16/complementares de
`rice.md` §10, transcritos literalmente) e gerador Python 3 (stdlib apenas) que escreve os
arquivos de cor "puros" (Tier A) para cada app com sintaxe própria.

Arquivos gerados nesta rodada (todos com header "GENERATED", não editar à mão):
- `.config/kitty/voidashi-colors.conf`
- `.config/foot/voidashi-colors.ini` (seção `[colors-dark]`, valores sem `#`)
- `.config/ghostty/voidashi-colors` (`background`/`foreground`/`cursor-*`/`selection-*` sem
  `#`, `palette = N=#hex` com `#`, seguindo a sintaxe real do ghostty)
- `.config/alacritty/conf.d/voidashi-colors.toml`
- `.config/hypr/conf/palette.lua` (tabela Lua com todas as escalas + estados semânticos;
  sintaxe validada com `luac -p`)
- `.config/theme/voidashi-colors.css` (partial GTK CSS com `@define-color` por token —
  diretório novo, ainda **não** consumido por nenhum app; isso acontece na etapa 3)

Nenhum config de app foi tocado ainda nesta etapa — só os arquivos gerados acima foram
criados. `scripts/config_files.conf` ainda não tem `~/.config/theme` nem `~/.config/swaync`
(fica pra etapa 3, quando esses diretórios passam a ser consumidos de verdade).

## 2 — Terminais (kitty/foot/ghostty/alacritty)

**Status:** concluído

Cada terminal aponta o include ativo pro `voidashi-colors.*` gerado; o include/tema antigo
(Kanagawa Dragon) fica comentado do lado, não apagado. `foot.ini` também manteve o
`#include=.../flexoki.ini` que já estava lá desativado.

Dois bugs achados no gerador ao validar de verdade com `foot --check-config` (não eram
visíveis só olhando o palette.json, só apareceram testando contra o parser real do foot):

- Comentário do header usava `;`, mas foot usa `#` para comentário — `;` virava tentativa
  de key/value e quebrava o parse.
- Cursor gerado numa seção `[cursor]` com chave `color` — essa chave foi removida do foot
  (mesma depreciação que o `CLAUDE.md` já documentava para `flexoki.ini`, eu só repeti o
  erro no gerador). Corrigido: cursor agora é a chave `cursor = <texto> <fundo>` dentro de
  `[colors-dark]`.

Ajuste feito fora do escopo estrito de cor, mas coberto pela seção "Surface hierarchy /
Transparency and blur" do `RICE-GUIDE.md` ("Terminals: opaque by default... stay above
~90%"): `ghostty`'s `background-opacity` estava em `0.8` (abaixo do piso) — subi pra
`0.92`. `kitty`/`alacritty` já estavam em `0.9`, no limite aceitável, não mexi.

Validado com os comandos do `CLAUDE.md`: kitty via `+runpy` (`bad_lines: []`),
`foot --check-config` (exit 0), `ghostty +validate-config` (exit 0),
`alacritty migrate --dry-run` (sem avisos).

## 3 — GTK CSS: waybar/wofi/wlogout + bring-up do swaync

**Status:** concluído

Conteúdo anterior (Kanagawa/Cachy) de cada CSS preservado como `style.kanagawa.css`
irmão, antes de reescrever o arquivo ativo com `@import` do partial compartilhado.

**Papéis aplicados** (modelo corrigido — foco/ativo/selecionado = Ice, não Bordeaux):
- waybar: `void-10` fundo da barra, `edge-20` borda, módulos em `ink-3` em repouso,
  workspace ativo em `ice-800`/`ice-400`, urgente/crítico em `alert-critical`, submap do
  Hyprland (`#mode`) em `alert-caution` (é um modo com consequência, não um erro).
- wofi: `void-20` lista, `void-30` campo de busca (um degrau mais claro, conforme
  `RICE-GUIDE.md`), item selecionado em `ice-700` + texto `ink-0`.
- wlogout: overlay em `void-30` com leve transparência (`alpha(@void-30, 0.92)`), botão em
  `void-20`, hover/focus em `ice-800`/`ice-400` (foco = Ice).
- swaync (arquivo novo, `style.css` não existia antes): superfície `void-20`, borda
  `edge-20` normal / `alert-*-border` por urgência, crítico usa `alert-critical-bg` +
  `alert-critical` no texto.

**Achados fora do escopo estrito de cor:**
- Trocar a fonte da barra pra Iosevka Extended (pedido pelo `RICE-GUIDE.md` — mono virou a
  voz primária, inclusive em módulos de barra) estourou a altura mínima da `waybar`
  (`Requested height: 30 is less than the minimum height: 32`). Subi `"height"` de 30 pra
  32 nas três configs — efeito colateral direto e trivial da troca de tipografia, não uma
  mudança funcional.
- `.config/waybar/style.css`/`floating/style.css` tinham `window#waybar { background-color:
  rgba(0, 0, 0, 0); }` — bar totalmente transparente. `RICE-GUIDE.md` diz explicitamente
  "Bars and panels: opaque, or at most ~92% opacity" (transparência pesada é o efeito mais
  "digital" que existe, contraria o princípio material-sobre-digital). Mudei pra `void-10`
  opaco.

**Pegadinha de validação encontrada:** testar o wofi com `--style <caminho do repo>`
explícito quebra a resolução do `@import` relativo (ele resolve pra um caminho errado,
tipo `/home/jeff/theme/...` em vez de `.../theme/...`). Rodando `wofi` sem flags (via o
symlink real `~/.config/wofi` → repo, que é como ele roda de verdade) o import relativo
funciona normal. Não decifrei a causa exata — só documentando pra não perder tempo com
isso de novo. Por causa disso, a validação real de CSS GTK passou a ser feita direto via
`Gtk.CssProvider` em Python (`gi.repository.Gtk`), não pelas flags de cada app — mais
confiável e não depende de como cada app resolve o caminho internamente.

**Bring-up do swaync:** criado `.config/swaync/style.css` do zero. Adicionado
`~/.config/theme` e `~/.config/swaync` ao `config_files.conf`, rodado
`scripts/backup-configs.sh install` (dry-run primeiro) pra symlinkar os dois de verdade —
não existiam em `$HOME` antes, então foi criação pura, nada sobrescrito. O swaync que já
estava rodando ao vivo recebeu `swaync-client --reload-css` e confirmou
`CSS reload success: true` — já está no tema novo agora, sem precisar reiniciar o daemon.

**Waybar (a barra que está de fato na tela agora) não foi recarregada ao vivo ainda** —
deixei pra fazer isso numa passada só, depois que o Hyprland (etapa 4) também estiver
pronto, pra não deixar a tela num estado misto (barra nova + bordas de janela antigas) no
meio do trabalho.

## 4 — Hyprland: `palette.lua` + bordas em `appearance.lua`

**Status:** pendente

## 5 — Apps menores: swaylock, fastfetch, bottom, starship, fish

**Status:** pendente

## 6 — Docs: nota no `CLAUDE.md`, linha nova em `rice.md` §13, checklist §15

**Status:** pendente

---

## Decisões tomadas ao longo do caminho

(Preenchido conforme surgem — qualquer escolha que os documentos de design não cobriam
diretamente e que precisou de julgamento na hora da implementação.)

### Correção — os docs foram reescritos em inglês e renomeados durante a etapa 1

Enquanto eu construía a infra (`palette.json` + `generate_theme.py`), Jeff reescreveu os
três documentos de design em paralelo: `system.md` → `DESIGN-SYSTEM.md`,
`rice.md` → `RICE-GUIDE.md`, `aesthetic-direction.md` → `AESTHETIC-DIRECTION.md`. Não foi
só tradução — o `RICE-GUIDE.md` novo muda decisões reais em relação à versão que eu tinha
lido antes de entrar em plan mode. `palette.json` já foi corrigido para refletir a versão
nova (é a atual, correta). O que mudou de verdade, para não repetir o erro em nenhuma
etapa futura:

- **Foco de janela agora é Ice, não Bordeaux.** O `RICE-GUIDE.md` tem uma tabela nova de
  "Role-based colour assignment": Foco/ativo/selecionado → **Ice**; Identidade/ação
  primária → **Bordeaux** (cursor de terminal, prompt, power menu, lockscreen). Ou seja:
  borda de janela ativa no Hyprland = Ice (não bordeaux-500/600 como eu tinha planejado);
  item selecionado no wofi = Ice (não bordeaux-deep/800).
- **Nova família Verdigris** para o slot ciano do ANSI (não existia antes — o cyan era
  "derivado" sem nome próprio). `verdigris-400 #459192` (slot 6) e `verdigris-300 #64a9a9`
  (slot 14). Só existe para uso em terminal/syntax — nunca como acento de UI.
  `palette.json` tem uma escala `verdigris` própria.
- **Cursor de terminal mudou de bordeaux-400 para bordeaux-300** (`#c76870`).
- **Fundo de seleção de terminal mudou de bordeaux-800 para ice-600** (`#215b7c`) — saiu
  da família de identidade para a de função.
- **"Estados semânticos" viraram "Alert tones"**, com nomes novos: `alert-critical`
  (era state-error), `alert-caution` (era state-warning), `alert-good` (era state-success),
  `alert-neutral` (era state-info). Hex de primeiro plano idênticos; fundo/borda também
  idênticos aos do `DESIGN-SYSTEM.md` §2.9 (o `RICE-GUIDE.md` não repete esses dois, só o
  fg — mantive bg/border porque nada os contradisse). `palette.json` usa a chave `alert`
  com `critical/caution/good/neutral`.
- **WCAG / alto contraste explicitamente não se aplica ao desktop** ("Not applicable to
  desktop work... this apparatus is dropped" — `RICE-GUIDE.md`). Removi o bloco
  `high_contrast` do `palette.json`.
- **Notificações usam `void-20`, não `void-30`** como eu tinha registrado no plano
  original.
- Nova seção "Working rules for Claude Code" dentro do próprio `RICE-GUIDE.md` — vale a
  pena reler antes de cada etapa futura, é curta e é dirigida a mim diretamente.

Nenhum arquivo de app tinha sido tocado ainda quando isso foi percebido (só os 6 arquivos
gerados da etapa 1, que já foram regenerados com os valores corretos) — nenhum retrabalho
de commit necessário.
