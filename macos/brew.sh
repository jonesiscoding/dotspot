#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

brew install bash-completion2
brew install imagemagick
brew install jhead
brew install exiftool
brew install ghostscript
brew install jq

# Remove outdated versions from the cellar.
brew cleanup
