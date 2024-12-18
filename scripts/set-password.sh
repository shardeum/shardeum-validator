#!/usr/bin/env bash

echo

docker-safe() {
  if ! command -v docker &>/dev/null; then
    echo "docker is not installed on this machine"
    exit 1
  fi

  if ! docker $@; then
    echo "Trying again with sudo..."
    sudo docker $@
  fi
}

read_password() {
  # Clear input buffer to avoid processing leftover inputs
  stty -icanon min 0 time 0  # Set non-canonical mode temporarily
  while read -r -t 0; do read -r; done  # Flush buffer
  stty sane  # Restore terminal to normal mode

  local CHARCOUNT=0
  local PASSWORD=""
  while IFS= read -p "$PROMPT" -r -s -n 1 CHAR; do
    # Enter - accept password
    if [[ $CHAR == $'\0' ]]; then
      break
    fi
    # Backspace
    if [[ $CHAR == $'\177' ]]; then
      if [ $CHARCOUNT -gt 0 ]; then
        CHARCOUNT=$((CHARCOUNT - 1))
        PROMPT=$'\b \b'
        PASSWORD="${PASSWORD%?}"
      else
        PROMPT=''
      fi
    else
      CHARCOUNT=$((CHARCOUNT + 1))
      PROMPT='*'
      PASSWORD+="$CHAR"
    fi
  done
  echo $PASSWORD
}

check_password() {
  local PASSWORD=$1
  local ERRORS=""

  if [[ ${#PASSWORD} -lt 8 ]]; then
    ERRORS+="Password must be at least 8 characters long.\n"
  fi

  if ! [[ "$PASSWORD" =~ [a-z] ]]; then
    ERRORS+="Password must contain at least one lowercase letter.\n"
  fi

  if ! [[ "$PASSWORD" =~ [A-Z] ]]; then
    ERRORS+="Password must contain at least one uppercase letter.\n"
  fi

  if ! [[ "$PASSWORD" =~ [0-9] ]]; then
    ERRORS+="Password must contain at least one number.\n"
  fi

  # Corrected special character check:
  if ! [[ "$PASSWORD" =~ [!@#$%^\&*()_+] ]]; then
    ERRORS+="Password must contain at least one special character (!@#$%^&*()_+$).\n"
  fi

  if [[ -n "$ERRORS" ]]; then
    echo -e "\nInvalid password. Please correct the following:\n$ERRORS"
    return 1
  else
    return 0
  fi
}

echo "Password requirements: "
echo -e "min 8 characters, at least 1 lower case letter, at least 1 upper case letter, at least 1 number, at least 1 special character !@#$%^&*()_+$ \n"

while true; do
  echo -n "Enter the password for accessing the Dashboard: "
  DASHPASS=$(read_password)

  if [ -z "$DASHPASS" ]; then
    echo "Password cannot be empty"
    continue
  fi
  echo
  if check_password "$DASHPASS"; then
    break
  fi
done

# Escape $ characters for docker command
ESCAPED_DASHPASS=$(printf '%s' "$DASHPASS" | sed 's/\$/\\\$/g')

docker-safe exec -it shardeum-validator operator-cli gui set password "$ESCAPED_DASHPASS"

echo
echo