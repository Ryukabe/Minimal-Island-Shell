# Simple user-level plugin manager function
function user_plugin() {
    local name=$1
    local repo=$2
    local dir="$ZDOTDIR/plugins/$name"

    # If the plugin doesn't exist, download it automatically
    if [ ! -d "$dir" ]; then
        echo "Downloading plugin: $name..."
        git clone --depth 1 "$repo" "$dir"
        
        # Remove the nested .git folder to avoid git tracking conflicts
        rm -rf "$dir/.git"
    fi

    # Source the plugin code
    if [ -f "$dir/$name.plugin.zsh" ]; then
        source "$dir/$name.plugin.zsh"
    elif [ -f "$dir/$name.zsh" ]; then
        source "$dir/$name.zsh"
    fi
}

# --- PLUGIN STACK ---
user_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions"
user_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
user_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

# Enable native git completions
autoload -Uz vcs_info