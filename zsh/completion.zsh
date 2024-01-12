# Autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select
# Rehash automatically
zstyle ':completion:*:commands' rehash true
# Verbose completion results
zstyle ':completion:*' verbose true
# Enable corrections
zstyle ':completion:*' completer _complete _correct
# Case-insensitive completion, completion of dashed values
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[_-]=* r:|=*'

autoload -Uz compinit && mkdir -p ~/.cache/zsh && compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION
