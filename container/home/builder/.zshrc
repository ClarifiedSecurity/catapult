# Keeping history in a separate mounted folder to avoid can't save history errors when exiting the container
HISTFILE=/home/builder/.history/.zsh_history

# Path to your oh-my-zsh installation.
export ZSH="/home/builder/.oh-my-zsh"

# Theme
ZSH_THEME="spaceship"

# Plugins
plugins=(git poetry)

# Sourcing oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Including better history
if [ -f ~/.fzf.zsh ]; then
    . ~/.fzf.zsh
fi

# Disabling globbing
unsetopt glob