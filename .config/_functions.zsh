#!/usr/bin/env zsh

if [[ -z "${HR:-}" ]]; then
  if [[ -n "${NO_COLOR:-}" || "$TERM" =~ ^(dumb|emacs)$ || -n "${CI:-}" ]] || ! command -v tput > /dev/null 2>&1; then
    RED="" && GREEN="" && YELLOW="" && BLUE="" && MAGENTA="" && CYAN="" && WHITE="" && RESET=""
  else
    RED=$(tput setaf 1) \
      && GREEN=$(tput setaf 2) \
      && YELLOW=$(tput setaf 3) \
      && BLUE=$(tput setaf 4) \
      && MAGENTA=$(tput setaf 5) \
      && CYAN=$(tput setaf 6) \
      && WHITE=$(tput setaf 7) \
      && RESET=$(tput sgr0)
  fi
  CHECK="${GREEN}✓${RESET}"
  CROSS="${RED}✗${RESET}"
  HR="---------------------------------------------"

  # shellcheck disable=SC2034
  typeset -gr RED GREEN YELLOW BLUE MAGENTA CYAN WHITE RESET CHECK CROSS HR
fi

# @brief Check if the current user can sudo
# @exitcode 0 user can likely use sudo
# @exitcode 1 user cannot use sudo
function can_sudo() {
    command -v /usr/bin/sudo >/dev/null 2>&1 || return 1
    id -Gn "${USER:-$(id -un)}" | grep -Eq '\b(admin|sudo|wheel)\b'
}

# @brief Check if the current system has Touch ID sensor available
# @exitcode 0 Touch ID sensor is available
# @exitcode 1 Touch ID sensor is not available
function can_touchid() {
  bioutil -r -s 2>/dev/null | grep -Eq '(Touch ID|Biometrics) functionality:[[:space:]]*1'
}

function touch_sudo() {
  grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' /etc/pam.d/sudo_local 2>/dev/null
}

function _check() {
  printf "\r\e[K${GREEN}%-1s${RESET} %s\n" "✓" "$1"
}

function _skip() {
  printf "\r\e[K${WHITE}%-1s${RESET} %s\n" "-" "$1"
}

function _cross() {
  printf "\r\e[K${RED}%-1s${RESET} %s\n" "✗" "$1"
}
