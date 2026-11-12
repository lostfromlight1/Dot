if status is-interactive

   # ==========================================
    # 1. AUTO-START TMUX (GUI ONLY)
    # ==========================================
    if test "$TERM" = "xterm-kitty"
        if not set -q TMUX
            exec tmux new-session -A -s main
        end
    end
    # ==========================================
    # 2. BOOTSTRAP FISHER (Plugin Manager)
    # ==========================================
    if not functions -q fisher
        set -q XDG_DATA_HOME; or set XDG_DATA_HOME ~/.local/share
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end

    # ==========================================
    # 3. ENVIRONMENT & INIT
    # ==========================================
    set -g fish_greeting ""                 # Disable the welcome message
    set -gx EDITOR nvim                     # Set Neovim as default editor
    set -gx VISUAL nvim

    # Initialize Starship Prompt
    starship init fish | source

    # Initialize Zoxide (Smarter 'cd')
    zoxide init fish | source

    # ==========================================
    # 4. SMART FASTFETCH AUTOSTART
    # ==========================================
    # The alias passes the raw Kitty image data directly through Tmux
    alias fastfetch='kitten icat -n --place 32x15@2x2 --scale-up --align left "$HOME/Pictures/Gifs/Chika.gif" | command fastfetch --logo-width 35 --logo-padding-top 1 --raw -'

    if test "$COLUMNS" -ge 100; and test "$LINES" -ge 30
        fastfetch
    else
        command fastfetch --logo none
    end   

    # ==========================================
    # 5. WAYLAND CLIPBOARD INTEGRATION
    # ==========================================
    function cpo --description 'Re-run last command and copy output to clipboard'
        set -l last_cmd $history[1]
        eval $last_cmd | wl-copy
        echo -e "\e[32m✔ Copied output of:\e[0m $last_cmd"
    end

    function copy_commandline
        commandline | wl-copy
        echo -e "\n\e[32m✔ Command copied!\e[0m"
        commandline -f repaint
    end
    bind \cy copy_commandline

    # ==========================================
    # 6. ALIASES 
    # ==========================================
    alias ..="cd .."
    alias ...="cd ../.."
    alias cd="z"           

    alias ls='lsd'
    alias l='lsd -l'
    alias la='lsd -a'
    alias lla='lsd -la'
    alias lt='lsd --tree'
    alias c="clear"

    alias vim="nvim"
    alias v="nvim"
    alias g="git"
    alias d="docker"
    alias dco="docker-compose"

    # ==========================================
    # 7. CATPPUCCIN MOCHA SYNTAX HIGHLIGHTING
    # ==========================================
    set -g fish_color_normal text
    set -g fish_color_command 89b4fa
    set -g fish_color_param f2cdcd
    set -g fish_color_keyword f38ba8
    set -g fish_color_quote a6e3a1
    set -g fish_color_redirection f5c2e7
    set -g fish_color_end fab387
    set -g fish_color_error f38ba8
    set -g fish_color_gray 6c7086
    set -g fish_color_selection --background=313244
    set -g fish_color_search_match --background=313244
    set -g fish_color_operator f5c2e7
    set -g fish_color_escape eba0ac
    set -g fish_color_autosuggestion 6c7086
    set -g fish_color_cancel f38ba8
    set -g fish_color_cwd f9e2af
    set -g fish_color_user 94e2d5
    set -g fish_color_host 89b4fa
    set -g fish_color_valid_path --underline
    set -g fish_pager_color_progress 6c7086
    set -g fish_pager_color_prefix f5c2e7
    set -g fish_pager_color_completion cdd6f4
    set -g fish_pager_color_description 6c7086

end
