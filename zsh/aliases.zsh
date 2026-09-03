# General Shortcuts
alias c='clear'
alias e='nvim'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'

# Safety & Utility Overrides
alias mkdir='mkdir -pv'
alias path='echo -e ${PATH//:/\\n}'
alias cp='cp -i'
alias mv='mv -i'

# Privilege Escalation (Polkit)
alias sudo='pkexec'

# Package Manager Shortcuts
alias i='yay --sudo pkexec -S'
alias s='yay -Ss'
alias u='yay --sudo pkexec -Rsn'

# Git Aliases
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

# Eza Overrides
alias ls='eza -l --icons'
alias la='eza -lah --icons --git'

# Clear forward and backward words
bindkey '^H' backward-kill-word # Ctrl + backspace
bindkey '^[[3;5~' kill-word     # Ctrl + delete

# History Search Bindings
bindkey '^R' history-incremental-search-backward # Ctrl + R (Reverse search)
bindkey '^[[A' up-line-or-search                  # Up Arrow (Search history matching prefix)
bindkey '^[[B' down-line-or-search                # Down Arrow (Search history matching prefix)