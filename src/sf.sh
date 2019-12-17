#!/bin/bash

self=$(basename $0)

declare -A commands

# Some initial example commands
commands=(
  ['start']="server:start"
  ['stop']="server:stop"
  ['cc']="cache:clear"
  ['dc']="debug:container"
  ['dr']="debug:router"
  ['ded']="debug:event-dispatcher"
  ['rm']="router:match"
  ['ccw']="cache:clear;cache:warmup #Two commands!" # Example of running two commands
)
# save command

commands_file_dir=".config/symfonyHelper/"
commands_file="$commands_file_dir/commands.sh"
user_commands_file_dir="$HOME/$commands_file_dir"
user_commands_file="$HOME/$commands_file"
if [ ! -f "$user_commands_file" ]; then
  mkdir -p "$user_commands_file_dir"
  declare -p commands >"$user_commands_file"
  chmod 700 "$user_commands_file"
fi
# shellcheck source=$HOME/.config/symfonyHelper/command.sh
source "$user_commands_file"

case $1 in
-l | --list)
  echo -e "\nList of commands: "
  for i in "${!commands[@]}"; do
    echo "$i" "${commands[$i]}"
  done | sort -n -k3 | column -t | sed 's/^/     /'
  echo ""
  exit 0
  ;;
-s | --set | -a | --add)
  commands["$2"]="$3"
  declare -p commands >"$user_commands_file"
  echo "Saved alias '$2' for command '$3'"
  exit 0
  ;;
-r | --remove)
  command="${commands[$2]}"
  unset commands["$2"]
  declare -p commands >"$user_commands_file"
  echo "Removed alias '$1' for command '$command'"
  exit 0
  ;;
-c | --check)
  command="${commands[$2]}"
  echo "$command"
  exit 0
  ;;
--send-commands-to)
  commands_text=$(cat $user_commands_file)
  ssh "$2" "mkdir -p '$commands_file_dir' && echo '$commands_text' > '$commands_file'"
  exit 0
  ;;
--copy-self-to)
  scp "$0" "$2:~/bin/$self"
  exit 0
  ;;
-h | --help | "")
    __usage="
Usage: $self [OPTIONS]
Running command: $self <alias> [<args>...] [COMMAND OPTIONS]
Options:
  -l, --list                   List all aliases commands.
  -s, --set <alias> <command>  Create new alias. E.g '-s do app:do:sth'
  -r, --remove <alias>         Remove alias.
  -c, --check <alias>          Check alias command.
  --send-commands-to <host>    Send local command to host
  --copy-self-to <host>        Copy $self to host to ~/bin directory
"
  echo "$__usage"
  exit 0
  ;;
*) # unknown option
  ;;
esac

# back to first symfony project in current path
while [ ! -d ./bin ] || [ ! -f ./bin/console ] || ! grep -q "<?php" bin/console; do
  if [ $PWD == '/' ]; then
    echo "Please use this script in php project with bin/console" 1>&2
    exit 1
  fi
  cd ./..
done

# Save first argument as our short command
short_command=$1
shift
arguments_copy=("$@")

# Resolving argument reference
for tmp; do
  tmp=$1
  case $tmp in
  '-prod')
    tmp="--env=prod"
    ;;
  '-dev')
    tmp="--env=dev"
    ;;
  '-test')
    tmp="--env=test"
    ;;
  esac

  pat='\$([0-9]+)'
  if [[ $tmp =~ $pat ]]; then # $pat must be unquoted
    another_argument="${BASH_REMATCH[1]}"
    another_argument=$(($another_argument - 1))
    tmp="${arguments_copy[another_argument]}"
  fi

  set -- "$@" "$tmp"
  shift
done

for i in "${!commands[@]}"; do
  if [ "$i" == "$short_command" ]; then
    IFS=';' read -ra array <<<"${commands[$i]}"
    for element in "${array[@]}"; do
      $self "$element" "$@"
    done
    exit 0
  fi
done

./bin/console "$short_command" "$@"
exit 0
