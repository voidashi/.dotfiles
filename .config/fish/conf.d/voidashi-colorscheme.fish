#!/usr/bin/fish

# Voidashi colorscheme (docs/design/RICE-GUIDE.md).
# Previous themes preserved, deactivated, in conf.d.legacy/ (fish autoloads every
# *.fish file in conf.d/, so only one colorscheme file can live here at a time).

# Syntax highlighting -- "Editors and syntax themes": ink for text, the identity
# families + Verdigris for syntax categories, comments at ink-4.
set -g fish_color_normal       b1b1b1  # ink-2
set -g fish_color_command      498bb2  # ice-400
set -g fish_color_keyword      9270a7  # ash-400
set -g fish_color_quote        4e9162  # moss-400
set -g fish_color_redirection  459192  # verdigris-400
set -g fish_color_end          459192  # verdigris-400
set -g fish_color_error        e14b39  # alert-critical
set -g fish_color_param        e8e8e8  # ink-0
set -g fish_color_operator     929292  # ink-3
set -g fish_color_comment      6c6c6c  # ink-4
set -g fish_color_autosuggestion 4d4d4d  # ink-5
set -g fish_color_escape       c76870  # bordeaux-300

# Selection / search match -- focus/active/selected = Ice
set -g fish_color_selection --background=215b7c      # ice-600
set -g fish_color_search_match --background=124560    # ice-700

# Completion pager
set -g fish_pager_color_description          6c6c6c  # ink-4
set -g fish_pager_color_selected_prefix       e8e8e8  # ink-0
set -g fish_pager_color_selected_completion   e8e8e8  # ink-0
set -g fish_pager_color_selected_description  e8e8e8  # ink-0
set -g fish_pager_color_selected_background --background=215b7c  # ice-600
