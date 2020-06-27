#!/bin/bash

source "../shared/sbin/functions.sh"
source "../shared/sbin/versions.sh"

if [ -z "${LOCAL_BIN}" ]; then
  LOCAL_BIN=~/.local/bin
fi
if [ -z "${LOCAL_SBIN}" ]; then
  LOCAL_SBIN=~/.local/sbin
fi

LINE="-----------------------------------------"

STATUS_DEV=false
STATUS_DOT=false

lstart() {
  becho "\nSTART: $1\n${LINE}"
}

lend() {
  becho "${LINE}\nEND: $1\n"
}

echo -e " "

# Install Composer
if ask "Install COMPOSER, BOX, and PLEASING?" Y; then
  # Make sure directory exists
  mkdir -p ${LOCAL_BIN}
  # Install Composer
  if [ ! -f "${LOCAL_BIN}/composer" ]; then
    doComposer
  else
    if ask "  Replace existing Composer binary?" Y; then
      doComposer
    fi
  fi
  # Install Box
  if [ ! -f "${LOCAL_BIN}/box" ]; then
    doBox
  else
    if ask "  Replace existing Box binary?" Y; then
      doBox
    fi
  fi
  # Install Pleasing
  if [ ! -f "${LOCAL_BIN}/pleasing" ]; then
    doPleasing
  else
    if ask "  Replace existing Pleasing binary?" Y; then
      doPleasing
    fi
  fi
fi

if ask "Install Docker Compose Utility?" Y; then
  # Make sure directory exists
  mkdir -p ${LOCAL_SBIN}
  # Install DK
  if [ ! -f "${LOCAL_SBIN}/dk" ]; then
    doDk
  else
    if ask "  Replace existing dk script?" Y; then
      doDk
    fi
  fi
fi

# Backup & Install DotFiles
if [ -f /usr/bin/rsync ]; then
  if ask "Install Dot Files?" Y; then
    # Backup DotFiles
    BKUP="$HOME/.dotbkup/$(date +"%Y%m%d")"
    mkdir -p ${BKUP}
    if [ -f $HOME/.gitattributes ]; then
      cp $HOME/.gitattributes ${BKUP}/
    fi
    if [ -f $HOME/.gitconfig ]; then
      cp $HOME/.gitconfig ${BKUP}/
    fi
    if [ -f $HOME/.gitignore ]; then
      cp $HOME/.gitignore ${BKUP}/
    fi
    if [ -f $HOME/.bashrc ]; then 
      cp $HOME/.bashrc ${BKUP}/
    fi
    if [ -f $HOME/.bash_profile ]; then 
      cp $HOME/.bash_profile ${BKUP}/
    fi
    becho "\n** NOTE: A backup of your dotfiles has been placed in ${BKUP} **\n"
    lstart "Installing Dot Files..."
    shopt -s dotglob
    rsync --exclude ".git/" \
      --exclude "macos" \
      --exclude "sbin" \
      --exclude "shared" \
      --exclude "chromeos" \
      --exclude "vscode" \
      --exclude "brew.sh" \
      --exclude ".dotbkup" \
      --exclude "bootstrap.sh" \
      --exclude "/.gitignore" \
      --exclude "functions/" \
      --exclude "README.md" \
      --exclude "LICENSE" \
      -avP --no-perms ./.* $HOME/
    lend "Installing Dot Files"
  fi
fi

if [ -f ~/.bash_profile ]; then
  source ~/.bash_profile
fi

becho "\nTo set some reasonable MacOS defaults, run the command '~/.macos'.  Note that sudo rights are required.";
becho "Some of the alterations made may also require that you run './brew.sh' to install dependencies.\n"
echo -e " "