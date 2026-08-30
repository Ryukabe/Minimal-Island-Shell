# General Shortcuts
alias c='clear'
alias e='nvim'
alias ..='cd ..'

# Privilege Escalation (Polkit / Quickshell)
alias sudo='pkexec'

# Package Manager Shortcuts
alias i='yay --sudo pkexec -S'
alias s='yay -Ss'
alias u='yay --sudo pkexec -Rsn'

# Privilege Escalation (Polkit / Quickshell)
#alias sudo='pkexec'

# Package Manager (yay)
#alias i='yay -S'
#alias s='yay -Ss'
#alias u='yay -Rsn'

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

# Eza Overrides (Uncomment to enable)
alias ls='eza -l --icons'
#alias ls='eza --icons'
#alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
#alias tree='eza --tree --icons'