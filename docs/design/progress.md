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

**Status:** pendente

## 3 — GTK CSS: waybar/wofi/wlogout + bring-up do swaync

**Status:** pendente

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
