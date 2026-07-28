#!/usr/bin/fish

# name: Flexoki Dark
# url: https://stephango.com/flexoki
# preferred_background: 100f0f # bg

set -g fish_color_normal	cecdc3 # tx
set -g fish_color_command	da702c # or
set -g fish_color_keyword	879a39 # gr
set -g fish_color_quote	3aa99f # cy
set -g fish_color_redirection	ce5d97 # ma
set -g fish_color_end		ce5d97 # ma
set -g fish_color_error	d14d41 # re
set -g fish_color_param	4385be # bl
set -g fish_color_operator	878580 # tx-2
set -g fish_color_comment	575653 # tx-3

set -g fish_pager_color_description b7b5ac # tx-3
set -g fish_pager_color_selected_prefix      100f0f # bg
set -g fish_pager_color_selected_completion  1c1b1a # bg-2
set -g fish_pager_color_selected_description 282726 # ui
set -g fish_pager_color_selected_background --background=cecdc3 # tx


# # Kanagawa Fish shell theme
# # A template was taken and modified from Tokyonight:
# # https://github.com/folke/tokyonight.nvim/blob/main/extras/fish_tokyonight_night.fish
# set -l foreground DCD7BA normal
# set -l selection 2D4F67 brcyan
# set -l comment 727169 brblack
# set -l red C34043 red
# set -l orange FF9E64 brred
# set -l yellow C0A36E yellow
# set -l green 76946A green
# set -l purple 957FB8 magenta
# set -l cyan 7AA89F cyan
# set -l pink D27E99 brmagenta

# # Syntax Highlighting Colors
# set -g fish_color_normal $foreground
# set -g fish_color_command $cyan
# set -g fish_color_keyword $pink
# set -g fish_color_quote $yellow
# set -g fish_color_redirection $foreground
# set -g fish_color_end $orange
# set -g fish_color_error $red
# set -g fish_color_param $purple
# set -g fish_color_comment $comment
# set -g fish_color_selection --background=$selection
# set -g fish_color_search_match --background=$selection
# set -g fish_color_operator $green
# set -g fish_color_escape $pink
# set -g fish_color_autosuggestion $comment

# # Completion Pager Colors
# set -g fish_pager_color_progress $comment
# set -g fish_pager_color_prefix $cyan
# set -g fish_pager_color_completion $foreground
# set -g fish_pager_color_description $comment