# shellcheck shell=bash

function _brewPath() {
  local BREW_BIN
  local ARCH

  if _isMac; then
    ARCH=$(/usr/bin/uname -m)
    if [ "$ARCH" == "x86_64" ]; then
      BREW_BIN="/usr/local/bin/brew"
    elif [ "$ARCH" == "arm64" ]; then
      BREW_BIN="/opt/homebrew/bin/brew"
    fi
  fi

  if [ -z "$BREW_BIN" ]; then
    return 1
  else
    echo $BREW_BIN
    return 0
  fi
}

function _phpPath() {
  local PHP_BIN
  local ARCH

  PHP_BIN=$(/usr/bin/which)
  if [ -z "$PHP_BIN" ]; then
    if _isMac; then
      if [ -f "/usr/bin/php" ]; then
        PHP_BIN="/usr/bin/php"
      else
        ARCH=$(/usr/bin/uname -m)
        if [ "$ARCH" == "x86_64" ]; then
          PHP_BIN="/usr/local/bin/php"
        elif [ "$ARCH" == "arm64" ]; then
          PHP_BIN="/opt/homebrew/bin/php"
        fi
      fi
    fi
  fi

  if [ -z "$PHP_BIN" ]; then
    return 1
  else
    echo $PHP_BIN
    return 0
  fi
}

function _version() {
  if [ -f "$HOME/.config/versions/$1" ]; then
    cat "$HOME/.config/versions/$1"
  fi

  return 0
}

function _skip() {
  local ITEM
  local PATTERN

  ITEM="$1"
  PATTERN="^${ITEM}$"

  if [ -f "$HOME/.skip" ]; then
    if /usr/bin/grep -q "'$PATTERN'" "$HOME/.skip"; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

function _isMac() {
 if [ "$(/usr/bin/uname -s)" == "Darwin" ]; then
   return 0;
 else
   return 1;
  fi
}

function _isMacSudo() {
  if [ "$HOME" != "/var/root" ]; then
    if /bin/test -w /var/root; then
      return 0
    fi
  fi

  return 1
}

function _isBrewing() {
  local BREW_BIN

  BREW_BIN=$(_brewPath)

  if [ -f "$BREW_BIN" ]; then
    return 0
  else
    return 1
  fi
}

function install_brew() {
  local BREW_BIN

  if _skip "brew"; then
    echo "Skipping Hombrew Install (present in .skip)"
    return 0
  fi

  if _isMac; then
    BREW_BIN=$(_brewPath)
    if [ -n "$BREW_BIN" ] && [ ! -f "$BREW_BIN" ]; then
      if _isSudo; then
        echo "Installing Homebrew..."
        echo "----------------------------------------------"
        if /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
          echo "----------------------------------------------"
          return 0
        else
          echo "----------------------------------------------"
          echo "ERROR: Homebrew installation failed, please see errors above."
          return 1
        fi
      elif [ "$USER" == "root" ]; then
        echo "ERROR: Homebrew cannot install as root.  Run the bootstrap as yourself, with sudo!"
        return 1
      else
        echo "Skipping Homebrew Install (User does not have 'sudo' rights)"
        return 0
      fi
    else
      echo "Skipping Homebrew Install (Already installed)"
      return 0
    fi
  else
    echo "Skipping Homebrew Install (not running macOS)"
    return 0
  fi
}

function install_brewfile() {
  local BREW_BIN
  local BIGLINE

  BIGLINE="-----------------------------------"

  if ! _isBrewing; then
    echo "ERROR: Cannot install items in .Brewfile.  Homebrew is not installed."
    return 1
  fi

  if _skip "Brewfile"; then
    echo "Skipping Brewfile (present in .skip)"
    return 0
  fi

  if [ -f "$HOME/.Brewfile" ] && [ ! -s "$HOME/.Brewfile" ]; then
    BREW_BIN=$(_brewPath)
    echo "Updating Homebrew bundle.."

    if "$BREW_BIN" bundle --global; then
      echo $BIGLINE
      return 0
    else
      echo $BIGLINE
      echo "ERROR: Could not install brew bundle!"
      return 1
    fi
  else
    echo "Skipping Brewfile (not present)"
  fi
}

function install_with_brew() {
  local BREW_BIN
  local FORMULA
  local VERSION
  local BIGLINE
  local NEEDLINK

  FORMULA="$1"
  BIGLINE="-----------------------------------"

  if ! _isBrewing; then
    echo "ERROR: Cannot install $FORMULA.  Homebrew is not installed."
    return 1
  fi

  if _skip "$FORMULA"; then
    echo "Skipping $FORMULA (present in .skip)"
    return 0
  fi

  BREW_BIN=$(_brewPath)
  if "$BREW_BIN" list | /usr/bin/grep -q "$FORMULA"; then
    return 0
  else
    VERSION=$(_version "$FORMULA")
    NEEDLINK=false
    if [ -n "$VERSION" ]; then
      if ! "$BREW_BIN" info --json php | /usr/bin/awk '/aliases/,/]/' | /usr/bin/grep -q "$VERSION"; then
        FORMULA="$FORMULA@$VERSION"
        NEEDLINK=true
      fi
    fi
    echo "Installing $FORMULA"
    echo $BIGLINE
    if ! "$BREW_BIN" install "$FORMULA"; then
      echo $BIGLINE
      echo "ERROR: $FORMULA was not successfully installed by Homebrew."
      return 1
    fi

    if $NEEDLINK; then
      if ! "$BREW_BIN" link "$FORMULA"; then
        echo $BIGLINE
        echo "ERROR: $FORMULA was installed but could not be linked by Homebrew."
        return 1
      fi
    fi

    echo $BIGLINE
    return 0
  fi

}

function install_php() {
  local PHP_BIN

  if _skip "php"; then
    echo "Skpping PHP install (present in .skip)"
    return 0
  fi

  if ! _isMac; then
    echo "Skipping PHP install (not running macOS)"
    return 0
  fi

  PHP_BIN=$(_phpPath)
  if [ -z "$PHP_BIN" ]; then
    echo "ERROR: Could not determine proper way to install PHP"
    return 1
  fi

  if [ -f "$PHP_BIN" ]; then
    echo "Skipping PHP Install (already installed)"
    return 0
  fi

  if install_with_brew "php"; then
    return 0
  else
    return 1
  fi
}

function install_composer() {
  local BIGLINE
  local PHP_BIN

  BIGLINE="-----------------------------------"

  if _skip "composer"; then
    echo "Skipping Composer install (present in .skip)"
    return 0
  fi

  if [ -f "$LOCAL_BIN/composer" ]; then
    echo "Skipping Composer install (already installed)"
    return 0
  fi

  PHP_BIN=$(_phpPath)
  if [ -z "$PHP_BIN" ] && [ ! -f "$PHP_BIN" ]; then
    echo "ERROR: Composer cannot be installed.  PHP is not installed."
    return 1
  fi

  echo "Installing Composer"
  echo $BIGLINE
  if ! /usr/bin/curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && /usr/bin/curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && $PHP_BIN -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && $PHP_BIN /tmp/composer-setup.php --no-ansi --install-dir="${LOCAL_BIN}" --filename=composer --snapshot \
    && /bin/rm -f /tmp/composer-setup.*; then
      echo $BIGLINE
      echo "ERROR: Composer not successfully installed!"
      return 1
  fi

  echo $BIGLINE

  return 0
}

function install_box() {
  local BOXVERSION
  local BOXURL
  local BOX_FILE
  local BIGLINE
  local PHP_BIN

  BIGLINE="-----------------------------------"

  if _skip "box"; then
    echo "Skipping Box install (present in .skip)"
    return 0
  fi

  if [ -f "$LOCAL_BIN/box" ]; then
    echo "Skipping Box install (already installed)"
    return 0
  fi

  PHP_BIN=$(_phpPath)
  if [ -z "$PHP_BIN" ] && [ ! -f "$PHP_BIN" ]; then
    echo "ERROR: Box cannot be installed.  PHP is not installed."
    return 1
  fi

  BOXVERSION=$(_version "box")
  if [ -z "$BOXVERSION" ]; then
    echo "ERROR: You must specify a version for Box in $HOME/.config/versions/box"
    return 1
  fi

  BOXURL=https://github.com/humbug/box/releases/download/${BOXVERSION}/box.phar
  echo "Installing Box..."
  echo $BIGLINE
  BOX_FILE=$(mktemp)
  if /usr/bin/curl -o "$BOX_FILE" -SL "${BOXURL}"; then
    if mv "${BOX_FILE}" "${LOCAL_BIN}/box" && chmod 755 "${LOCAL_BIN}"/box; then
      echo $BIGLINE
      return 0
    fi
  fi

  echo $BIGLINE
  echo "ERROR: Box was not installed properly."
  return 1
}