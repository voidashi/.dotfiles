#!/bin/bash
# Seleciona um wallpaper aleatório e imprime o caminho dele em stdout.
#
# Uso: select-random-wallpaper.sh DIR [DIR_FALLBACK...]
#
# Percorre os diretórios na ordem em que foram passados e usa o primeiro que
# contenha imagens. Isso reflete a convenção deste repositório:
#
#   ~/Pictures/Current_wallpapers  ->  os que estão em rotação agora
#   ~/Pictures/Wallpapers          ->  a coleção completa
#   ~/.dotfiles/wallpapers         ->  o wallpaper de exemplo do repo
#
# Assim uma instalação nova funciona sem nenhum setup: se as duas primeiras
# pastas ainda não existem, cai no wallpaper que vem junto do repositório.
#
# IMPORTANTE: mensagens de erro vão para stderr. Indo para stdout, o $(...)
# de quem chama capturaria a mensagem e a passaria como nome de arquivo:
# era exatamente esse o bug que deixava o swaybg sem wallpaper no Sway.

set -uo pipefail

if [ "$#" -eq 0 ]; then
    echo "uso: $(basename "$0") DIR [DIR_FALLBACK...]" >&2
    exit 1
fi

for dir in "$@"; do
    [ -d "$dir" ] || continue

    # -print0 com shuf -z lida com nomes de arquivo que contenham espaços.
    file="$(find -L "$dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
           -o -iname '*.webp' -o -iname '*.bmp' \) -print0 2>/dev/null \
        | shuf -z -n 1 | tr -d '\0')"

    if [ -n "$file" ]; then
        echo "$file"
        exit 0
    fi
done

echo "Nenhuma imagem encontrada em: $*" >&2
exit 1
