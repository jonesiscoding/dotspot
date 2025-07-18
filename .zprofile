# shellcheck shell=zsh

# Aliases
source .zaliases;

# Allow for autocorrection, globbing, cd options
setopt CORRECT_ALL
setopt AUTO_CD
setopt NO_CASE_GLOB

# History
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY
bindkey '^[[A' up-line-or-search # up arrow
bindkey '^[[B' down-line-or-search # down arrow

# Functions
fpath+=~/.zfunctions
autoload cdf
autoload dataurl
autoload digga
autoload finder
autoload fs
autoload ssh-keygen
autoload ssh-copy-id

# Prompt in Repos
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git

# Autocompletion
autoload -Uz compinit && compinit

#
# Conditional Functions
#

# Use Git’s colored diff when available
if hash git &>/dev/null; then
	diff() {
		git diff --no-index --color-words "$@";
	}
fi;

#
# Application Shortcuts Via Path
#

# PHPStorm Shortcut
if [ -x "/Applications/PhpStorm.app/Contents/MacOS/phpstorm" ] && [ ! -L /usr/local/bin/phpstorm ]; then
  export PATH="$PATH:/Applications/PhpStorm.app/Contents/MacOS"
fi

# PyCharm Shortcut
if [ -x "/Applications/PyCharm CE.app/Contents/MacOS/pycharm" ] && [ ! -L /usr/local/bin/pycharm ]; then
  export PATH="$PATH:/Applications/PyCharm CE.app/Contents/MacOS"
fi

# VSCode Shortcut
if [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ] && [ ! -L /usr/local/bin/code ]; then
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi


