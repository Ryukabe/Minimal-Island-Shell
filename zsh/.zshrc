# --- 1. POWERLEVEL10K INSTANT PROMPT ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh installation
export ZSH="$ZDOTDIR/ohmyzsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# --- 2. COMPLETION ENGINE ---
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# --- 3. LOAD MODULAR CONFIGURATIONS ---
source "$ZDOTDIR/options.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/aliases.zsh"

# --- 4. THEME LOADING ---
source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"

# Load P10k configuration preferences
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh