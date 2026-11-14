# dotspot

Dotfiles and bootstrap for macOS 12+

## Working with YOUR dotfiles

If you have your own dotfiles that you'd like to still use, while benefiting from the conveniences in my dotfiles, that is pretty simple to do.

Simply source your files in `.zprofile` or `.bash_profile`, or make your additions directly in those files. When you pull updates with `dot pull`, your changes will be stashed, and if possible, automatically popped.

## Installation

To perform the initial installation:

    curl -fsSL  https://raw.githubusercontent.com/jonesiscoding/dotspot/HEAD/.config/install | zsh

To bootstrap your environment, SSH config, and set macOS defaults, run:

    ~/.config/bootstrap --env --ssh --prefs

## Pulling Updates

To pull updates to the dotfiles while preserving your own changes, run:

    dot pull

Your changes will be stashed, and if possible, automatically popped.

## Credits

Many of the concepts in these dotfiles came from others on the web, as is the nature of things.

* Mathias Bynens (https://mths.be/dotfiles)
