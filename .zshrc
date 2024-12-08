ZSH_DISABLE_COMPFIX="true"

export DOTFILES=~/Projects/dotfiles

# Setup zsh completion
source $DOTFILES/zsh/completion.zsh
source <(~/bin/kubectl completion zsh)

# Setup https://github.com/zsh-users/zsh-autosuggestions
source ~/Projects/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable colors in prompt
autoload -Uz colors && colors

# Find and set branch name var if in git repository.
function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '('$branch') '
  fi
}

# Enable substitution in the prompt.
setopt prompt_subst

# Config for prompt.
prompt='%{$fg[cyan]%}% %2/ %{$fg[red]%}$(git_branch_name)%{$reset_color%}% > ' 

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setting up rg as search engine for fzf
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# Remap § to `
# See https://gist.github.com/paultheman/808be117d447c490a29d6405975d41bd.
# Use hidutil property --set '{"UserKeyMapping":[]}' to revert.
function remap_backtick() {
  hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035},{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064}]}'
}

remap_backtick()

# point testcontainers to docker runtime
export DOCKER_HOST="unix://${HOME}/.colima/docker.sock"

# Git aliases
alias gs="git status"
alias gf="git fetch"
alias gl="git log"
alias gr="git rebase"
alias gp="git pull"
alias gcm="git checkout master"

alias cl="clear"
alias r="python3 ~/Software/ranger/ranger.py"
alias s="sbt"
alias v=nvim
alias p=python3
alias ml="tail -f .metals/metals.log"
alias ll="ls -lah"

precmd () {print -Pn "\e]0;%~\a"}

export PATH=/opt/homebrew/bin:~/Software/jdk-17.0.2.jdk/Contents/Home/bin:~/Library/Application\ Support/Coursier/bin:~/bin:$PATH

# zsh history setup
export HISTSIZE=500000
export SAVEHIST=500000
setopt appendhistory
setopt INC_APPEND_HISTORY  
setopt SHARE_HISTORY
