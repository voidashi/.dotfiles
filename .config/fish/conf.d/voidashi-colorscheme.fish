#!/usr/bin/fish

# Voidashi colorscheme (docs/design/RICE-GUIDE.md).
#
# Este arquivo define TODAS as variaveis de cor do fish, de proposito. Antes
# definia so as 19 mais visiveis, e o fish_frozen_theme.fish, que o proprio
# fish gerou ao migrar para a versao 4.3, definia 27. O conf.d carrega em ordem
# alfabetica, entao o nosso vencia onde coincidia e as outras doze ficavam nas
# cores de fabrica: o cwd em green, o status em red, o usuario em brgreen e o
# progresso do pager em brwhite sobre fundo cyan. Passou despercebido porque a
# parte que se olha primeiro, a sintaxe da linha, estava certa.
#
# O check_palette.py nao pegava isso porque sao nomes de cor e nao hex; passou
# a pegar. Cobrir a lista inteira aqui e o que impede a lacuna de voltar.

# ===== Sintaxe da linha de comando =====
# "Editors and syntax themes": ink para texto, as familias de identidade mais
# Verdigris para as categorias, comentarios em ink-4.
set -g fish_color_normal         b1b1b1  # ink-2
set -g fish_color_command        498bb2  # ice-400
set -g fish_color_keyword        9270a7  # ash-400
set -g fish_color_quote          4e9162  # moss-400
set -g fish_color_redirection    459192  # verdigris-400
set -g fish_color_end            459192  # verdigris-400
set -g fish_color_error          e14b39  # alert-critical
set -g fish_color_param          e8e8e8  # ink-0
set -g fish_color_option         b1b1b1  # ink-2
set -g fish_color_operator       929292  # ink-3
set -g fish_color_comment        6c6c6c  # ink-4
set -g fish_color_autosuggestion 4d4d4d  # ink-5
set -g fish_color_escape         c76870  # bordeaux-300

# Caminho existente: sublinhado em vez de cor propria. Cor ja carrega outra
# informacao nessa posicao, e forma distingue sem competir com ela.
set -g fish_color_valid_path --underline

# ===== Selecao e busca =====
# Foco/ativo/selecionado = Ice, como em todo o resto do desktop.
set -g fish_color_selection --background=215b7c     # ice-600
set -g fish_color_search_match --background=124560  # ice-700
set -g fish_color_history_current --bold

# ===== Prompt =====
# O prompt e desenhado pelo starship, entao estas aparecem apenas em prompts
# internos do fish e em builtins. Mesmos papeis do resto: Bordeaux e a marca de
# identidade, e root e host remoto usam alert tones por serem estados com
# consequencia.
set -g fish_color_cwd            498bb2  # ice-400
set -g fish_color_cwd_root       e14b39  # alert-critical
set -g fish_color_user           c76870  # bordeaux-300
set -g fish_color_host           b1b1b1  # ink-2
set -g fish_color_host_remote    d89529  # alert-caution
set -g fish_color_status         e14b39  # alert-critical
set -g fish_color_cancel -r

# ===== Pager de completions =====
set -g fish_pager_color_progress             6c6c6c  # ink-4
set -g fish_pager_color_prefix               6aa3c7 --bold  # ice-300
set -g fish_pager_color_completion           b1b1b1  # ink-2
set -g fish_pager_color_description          6c6c6c  # ink-4
set -g fish_pager_color_selected_prefix      e8e8e8  # ink-0
set -g fish_pager_color_selected_completion  e8e8e8  # ink-0
set -g fish_pager_color_selected_description e8e8e8  # ink-0
set -g fish_pager_color_selected_background --background=215b7c  # ice-600
