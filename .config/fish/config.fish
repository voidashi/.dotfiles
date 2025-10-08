if status is-interactive
    # Commands to run in interactive sessions can go here
    
    starship init fish | source
    
    alias ls="exa --icons"
    alias cat="bat"

end

function fish_greeting

    #pfetch
    #catnap -d arch
    fastfetch --config ~/.config/fastfetch/arch_small/config.jsonc

end
