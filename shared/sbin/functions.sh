black="\033[0;30m"
blackb="\033[1;30m"
white="\033[0;37m"
whiteb="\033[1;37m"
red="\033[0;31m"
redb="\033[1;31m"
green="\033[0;32m"
greenb="\033[1;32m"
yellow="\033[0;33m"
yellowb="\033[1;33m"
blue="\033[0;34m"
blueb="\033[1;34m"
purple="\033[0;35m"
purpleb="\033[1;35m"
lightblue="\033[0;36m"
lightblueb="\033[1;36m"
end="\033[0m"

becho() {
  echo -e "${lightblueb}${1}${end}";
}

lstart() {
  becho "\nSTART: $1\n${LINE}"
}

lend() {
  becho "${LINE}\nEND: $1\n"
}

indent() { sed 's/^/  /'; }

# This is a general-purpose function to ask Yes/No questions in Bash, either
# with or without a default answer. It keeps repeating the question until it
# gets a valid answer.

ask() {
    # https://djm.me/ask
    local prompt default reply

    if [ "${2:-}" = "Y" ]; then
        prompt="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        prompt="y/N"
        default=N
    else
        prompt="y/n"
        default=
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -e -n "${purpleb}$1 ${end}[$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

function doComposer() {
  lstart "Installing Composer..."
  curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=${LOCAL_BIN} --filename=composer --snapshot \
    && rm -f /tmp/composer-setup.*
  lend "Installing Composer"
}

function doBox() {
  lstart "Installing Box..."
  BOX_FILE=$(mktemp)
  curl -o "$BOX_FILE" -SL "${BOXURL}"
  mv ${BOX_FILE} ${LOCAL_BIN}/box; chmod 755 ${LOCAL_BIN}/box
  lend "Installing Box"
}

function doDk() {
  lstart "Installing Docker Compose Util..."
  cp -v "../shared/docker/dk" "${LOCAL_SBIN}/"; chmod 755 ${LOCAL_SBIN}/dk
  lend "Installing Docker Compose Util..."
}

function doPleasing() {
  lstart "Installing Pleasing..."
  PLEASING_FILE=$(mktemp)
  curl -o "$PLEASING_FILE" -SL "${PLEASINGURL}"
  mv ${PLEASING_FILE} ${LOCAL_BIN}/pleasing
  chmod 755 ${LOCAL_BIN}/pleasing
  lend "Installing Pleasing"
}

function includePhpAddons() {
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
}