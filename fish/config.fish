if status is-interactive
    # Disable default greeting message
    set -g fish_greeting

    # Initialize Starship Prompt
    starship init fish | source

    # --- ALIASES ---
    # General & Navigation
    alias c='clear'
    alias e='nvim'
    alias ..='cd ..'
    alias .2='cd ../..'
    alias .3='cd ../../..'

    # Safety Overrides
    alias mkdir='mkdir -pv'
    alias cp='cp -i'
    alias mv='mv -i'

    # Privilege Escalation & Package Management (Arch/yay)
    alias sudo='pkexec'
    alias i='yay --sudo pkexec -S'
    alias s='yay -Ss'
    alias u='yay --sudo pkexec -Rsn'

    # Git
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit -m"
    alias gp="git push"
    alias gl="git log --all --graph"
    alias gcl="git clone"
    alias gpl="git pull"
    alias gst="git stash"
    alias gsp="git stash; git pull"
    alias gfo="git fetch origin"
    alias gcheck="git checkout"
    alias gcredential="git config credential.helper store"
    alias gcan="git commit --amend --no-edit"

    # Eza / Eza Alternatives
    alias ls='eza -l --icons'
    alias la='eza -lah --icons --git'

    # --- KEY BINDINGS ---
    # Ctrl + Backspace to delete word backward
    bind \cH backward-kill-word
    # Ctrl + Delete to delete word forward
    bind \e\[3\;5~ kill-word
end

# Custom PATH printing function
#function path
#    string join \n $PATH
#end