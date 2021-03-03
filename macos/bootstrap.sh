#!/bin/bash

source "../shared/sbin/versions.sh"
source "../shared/sbin/functions.sh"
if [ -f "$HOME/.exports" ]; then
  # shellcheck source=./.exports
  source "$HOME/.exports"
fi


# Status variables used later
STATUS_DEV=false
STATUS_DOT=false

# Start off with a blank line
echo -e " "

# Make sure local directories are in order
if [ -n "${DEV_DIR}" ]; then
  # Create the Directory
  [ ! -d "${DEV_DIR}" ] && mkdir -p "${DEV_DIR}"

  # Assert Local BIN
  if [ -z "${LOCAL_BIN}" ]; then
    if [ -w "/usr/local/bin" ]; then
      LOCAL_BIN="/usr/local/bin"
    else
      LOCAL_BIN="${DEV_DIR}/.local/bin"
    fi
  fi

  # Assert Local SBIN
  if [ -z "${LOCAL_SBIN}" ]; then
    if [ -w "/usr/local/sbin" ]; then
      LOCAL_SBIN="/usr/local/sbin"
    else
      LOCAL_SBIN="${DEV_DIR}/.local/sbin"
    fi
  fi
else
  [ -z "${LOCAL_BIN}" ] && LOCAL_BIN="/usr/local/bin"
  [ -z "${LOCAL_SBIN}" ] && LOCAL_SBIN="/usr/local/sbin"
fi

[ ! -d "${LOCAL_BIN}" ] && mkdir -p "${LOCAL_BIN}"
[ ! -d "${LOCAL_SBIN}" ] && mkdir -p "${LOCAL_SBIN}"

if [ ! -w "${LOCAL_BIN}" ] || [ ! -w "${LOCAL_SBIN}" ]; then
  echo "ERROR: Cannot write to ${LOCAL_BIN} or ${LOCAL_SBIN}. That means we have nowhere to put scripts."
  exit 1
fi

# Prompt for installation of Composer, Box, Pleasing
includePhpAddons

# Prompt for installation of Docker Compose Helper
if ask "Install Docker Compose Utility?" Y; then
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
    for file in $HOME/.{gitattributes,gitconfig,gitignore,bashrc,bash_profile}; do
      [ ! -d "${BKUP}" ] && mkdir -p "${BKUP}"
      if [ -f "$file" ]; then
        cp "$file" "${BKUP}/"
      fi
    done;
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
  # shellcheck source=./.bash_profile
  source ~/.bash_profile
fi

becho "\nTo set some reasonable MacOS defaults, run the command '~/.macos'.  Note that sudo rights are required.";
becho "Some of the alterations made may also require that you run './brew.sh' to install dependencies."
echo -e " "