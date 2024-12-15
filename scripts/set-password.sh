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
  while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
  do
    # Enter - accept password
    if [[ $CHAR == $'\0' ]] ; then
      break
    fi
    # Backspace
    if [[ $CHAR == $'\177' ]] ; then
      if [ $CHARCOUNT -gt 0 ] ; then
        CHARCOUNT=$((CHARCOUNT-1))
        PROMPT=$'\b \b'
        PASSWORD="${PASSWORD%?}"
      else
        PROMPT=''
      fi
    else
      CHARCOUNT=$((CHARCOUNT+1))
      PROMPT='*'
      PASSWORD+="$CHAR"
    fi
  done
  echo $PASSWORD
}

echo  "Password requirements: "
echo -n -e "min 8 characters, at least 1 lower case letter, at least 1 upper case letter, at least 1 number, at least 1 special character !@#$%^&*()_+$ \nSet the password to access the Dashboard:"
DASHPASS=$(read_password)

if [ -z "$DASHPASS" ]; then
    echo "Password cannot be empty"
    exit 1
fi

docker-safe exec -it shardeum-validator operator-cli gui set password "$DASHPASS" 

echo 
echo