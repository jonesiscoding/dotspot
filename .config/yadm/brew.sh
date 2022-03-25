#!/usr/bin/env bash

source "versions.sh"
source "functions.sh"

PACKAGES=("bash-completion2")

lstart "Updating Homebrew"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

lend "Updating Homebrew"
echo ""

# Ask About Packages
if ask "Install ImageMagick?" Y; then
 PACKAGES+=("imagemagick")
fi

if ask "Install GhostScript?" Y; then
  PACKAGES+=("ghostscript")
fi

if ask "Install ExifTool?" Y; then
  PACKAGES+=("exiftool")
fi

if ask "Install jhead Binary?" Y; then
  PACKAGES+=("jhead")
fi

if ask "Install sassc Binary?" Y; then
  PACKAGES+=("sassc")
fi

if ask "Install jq Binary?" Y; then
  PACKAGES+=("jq")
fi

if ask "Install yq Binary?" Y; then
  PACKAGES+=("yq")
fi

if ask "Install unison Binary?" Y; then
  PACKAGES+=("unison")
  PACKAGES+=("unison-fsmonitor")
fi

lstart "Installing Homebrew Packages"

# Install Packages
for PACKAGE in "${PACKAGES[@]}"
do
  brew install "$PACKAGE"
done

# Remove outdated versions from the cellar.
brew cleanup

lend "Installing Homebrew Packages"