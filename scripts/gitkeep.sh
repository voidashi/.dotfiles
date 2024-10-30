#!/bin/bash

# Percorre todos os diretórios a partir do diretório atual, ignorando o diretório .git
find . -type d -empty -not -path '*/.git/*' | while read dir; do
    touch "$dir/.gitkeep" # Cria o arquivo .gitkeep em diretórios vazios
    echo "Criado: $dir/.gitkeep"
done

