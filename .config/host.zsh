#!/usr/bin/env zsh

function configure_host() {
  local hostname="$1"
  local shortname domain current_hostname

  echo -e "\n${MAGENTA}Configuring hostname settings...${RESET}\n"

  if [[ "$hostname" == *.* ]]; then
    shortname="${hostname%%.*}"
  else
    domain=$(scutil --dns | grep -E "domain\[[0-9]+\]" | awk -F':' '{ print $2 }' | head -1 | xargs)
    shortname="$hostname"
    hostname="$shortname.$domain"
  fi

  if ! can_sudo; then
    _cross "Set Hostname ($hostname)"
    echo "  ${RED}Sudo privileges are required to set the hostname.${RESET}"
    exit 1
  fi

  current_hostname=$(scutil --get HostName 2>/dev/null)
  if [[ "$current_hostname" == "$hostname" ]]; then
    _skip "Set Hostname ($hostname)"
  elif scutil --set HostName "$hostname" && scutil --set LocalHostName "$shortname" && scutil --set ComputerName "$shortname"; then
    _check "Set Hostname ($hostname)"
  else
    _cross "Set Hostname ($hostname)"
  fi

  if ! grep -v '^[[:space:]]*#' /etc/hosts | grep -iwq "$hostname"; then
    _check "Update /etc/hosts ($hostname)"
    echo "Adding $hostname to /etc/hosts..."
    printf "%s\t%s %s\n" "127.0.0.1" "$hostname" "$shortname" | sudo tee -a /etc/hosts >/dev/null
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
  else
      _skip "Update /etc/hosts ($hostname)"
      echo "$hostname is already present in /etc/hosts."
  fi
}

if [[ ! $zsh_eval_context =~ 'file' ]]; then
  configure_host "$@"
fi