# shellcheck shell=zsh

# Load the shell dotfiles, and then some:
# * ~/.exports can be used to export `$PATH`.
# * ~/.local can be used for other settings you don’t want to commit.
for file in $HOME/.{exports,host,aliases,functions}; do
	if [ -r "$file" ] && [ -f "$file" ]; then
	  # shellcheck source=.exports
    # shellcheck source=.aliases
    # shellcheck source=.functions
	  source "$file";
	  if [ -r "$file.local" ] && [ -f "$file.local" ]; then
	    # shellcheck disable=SC1090
	    source "$file.local"
	  fi
	fi
done;
unset file;

# Allow for autocorrection, globbing, cd options
setopt correctall
setopt autocd
setopt nocaseglob

# Don't muck up history
setopt histignoredups
setopt histignorespace
setopt histappend

# Autocompletion
autoload -Uz compinit
compinit


