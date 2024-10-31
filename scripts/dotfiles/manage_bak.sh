#!/bin/bash

# Diretórios e arquivos de configuração
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_FILE="$HOME/scripts/dotfiles/dotfiles.conf"

# Função para inicializar o diretório de dotfiles e Git
init_dotfiles() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        mkdir -p "$DOTFILES_DIR"
        git init "$DOTFILES_DIR"
        echo "Repositório de .dotfiles inicializado em $DOTFILES_DIR"
    else
        echo "$DOTFILES_DIR já existe."
    fi
}

# Função para mover arquivo e criar symlink
add_dotfile() {
    local target="$1"
    # Substituindo ~ por $HOME
    target="${target/#\~/$HOME}"
    local dest="$DOTFILES_DIR/${target#$HOME/}"

    if [ -L "$target" ]; then
        echo "$target já está linkado."
    elif [ -e "$dest" ]; then
        echo "Aviso: $dest já existe no .dotfiles. Arquivo não será movido."
    else
        mkdir -p "$(dirname "$dest")"  # Cria diretórios necessários
        mv "$target" "$dest"           # Move o arquivo para .dotfiles
        ln -s "$dest" "$target"        # Cria o symlink
        echo "$target adicionado e linkado ao .dotfiles"

        # Sugestão de commit
        echo "Deseja fazer commit das alterações no Git? [s/n]"
        read -r resposta
        if [[ "$resposta" == "s" || "$resposta" == "S" ]]; then
            git_add_commit "$target"
        fi
    fi
}


# Função para ler o arquivo .conf e adicionar dotfiles
add_dotfiles() {
    local dotfiles
    dotfiles=$(load_dotfiles)

    for file in $dotfiles; do
        add_dotfile "$file"
    done
}

# Função para restaurar arquivos originais
restore_dotfile() {
    local target="$1"
    # Substituindo ~ por $HOME
    target="${target/#\~/$HOME}"
    local dest="$DOTFILES_DIR/${target#$HOME/}"

    if [ -L "$target" ]; then
        rm "$target"                    # Remove o symlink
        mv "$dest" "$target"            # Restaura o arquivo original
        echo "$target restaurado para o local original"
    else
        echo "$target não é um symlink, nada para restaurar."
    fi
}


# Função para carregar os dotfiles do arquivo de configuração
load_dotfiles() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Arquivo de configuração $CONFIG_FILE não encontrado!"
        exit 1
    fi

    grep -v '^#' "$CONFIG_FILE" | grep -v '^$'
}

# Função para verificar se os symlinks estão corretos
check_dotfiles() {
    while IFS= read -r file; do
        # Substituindo ~ por $HOME
        local target="${file/#\~/$HOME}"
        local dest="$DOTFILES_DIR/${target#$HOME/}"

        if [ -L "$target" ]; then
            if [ "$(readlink "$target")" == "$dest" ]; then
                echo "$target está corretamente linkado."
            else
                echo "$target linkado incorretamente."
            fi
        else
            echo "$target não é um symlink ou não está configurado."
        fi
    done < <(load_dotfiles)
}


# Função para sugerir e realizar commit no Git
git_add_commit() {
    local file="$1"
    local dest="$DOTFILES_DIR/${file#$HOME/}"

    git -C "$DOTFILES_DIR" add "$dest"
    git -C "$DOTFILES_DIR" commit -m "Adicionado $file a .dotfiles e criado symlink"
    echo "Alterações de $file foram commitadas no repositório Git."
}

# Menu para controlar as funções
case "$1" in
    init)
        init_dotfiles
        ;;
    add)
        add_dotfiles
        ;;
    restore)
        restore_dotfile "$2"
        ;;
    check)
        check_dotfiles
        ;;
    *)
        echo "Uso: $0 {init|add|restore [file]|check}"
        ;;
esac

