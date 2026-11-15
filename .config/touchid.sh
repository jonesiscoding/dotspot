#!/usr/bin/env zsh

function touch_sudo() {
  grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' /etc/pam.d/sudo_local 2>/dev/null
}

function configure_touch_sudo() {
  if can_sudo; then
    if touch_sudo; then
      _skip "Enable TouchID sudo (Enabled)"
      return 0
    fi

    if ! bioutil -r -s 2>/dev/null | grep -Eq 'Touch ID functionality:[[:space:]]*1'; then
      $isDebug && _cross "Enable TouchID sudo (No Sensor)"
      return 1
    fi

    if ! bioutil -c 2>/dev/null | grep -Eq '[1-9][0-9]* fingerprint'; then
      $isDebug && _cross "Enable TouchID sudo (No Fingerprint)"
      return 1
    fi
    
    echo -e "-- ${YELLOW} Requesting sudo to enable TouchID for sudo${RESET} --\n"
    if sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local > /dev/null; then
       _check "Enable TouchID sudo"
    else
       _cross "Enable TouchID sudo"
       return 1
    fi
  else
    $isDebug && _cross "Enable TouchID sudo (No Rights)"
  fi

  return 0
}

if [[ ! $zsh_eval_context =~ 'file' ]]; then
  configure_touch_sudo "$@"
fi
