if status is-interactive
    # Commands to run in interactive sessions can go here
    
    starship init fish | source
    
    # "exa" hoje é só um symlink de compatibilidade do pacote eza
    # (o exa original está sem manutenção desde 2023).
    alias ls="eza --icons"
    alias cat="bat"

end

function fish_greeting

    #pfetch
    #catnap -d arch
    fastfetch --config ~/.config/fastfetch/arch_small/config.jsonc

end
export PATH="$HOME/.local/bin:$PATH"
