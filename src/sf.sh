#!/bin/bash

declare -A commands
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

user_commands_file_dir="$HOME/.config/symfonyHelper"
user_commands_file="$user_commands_file_dir/commands.sh"
if [ ! -f "$user_commands_file" ]; then
  mkdir -p "$user_commands_file_dir"
  declare -p commands >"$user_commands_file"
  chmod 700 "$user_commands_file"
fi
# shellcheck source=$HOME/.config/symfonyHelper/command.sh
source "$user_commands_file"

# help
if [ "$1" == '-h' ] || [ "$1" == '--help' ] || [ "$1" == "" ]; then
  __usage="
Usage: $(basename $0) [OPTIONS]
Running command: $(basename $0) <alias> [<args>...] [COMMAND OPTIONS]
Options:
  -l, --list                   List all aliases commands.
  -s, --set <alias> <command>  Create new alias. E.g '-s do app:do:sth'
"
  echo "$__usage"
  exit 0
fi

if [ "$1" == '-l' ] || [ "$1" == '--list' ]; then
  for i in "${!commands[@]}"; do
    printf "    %-10s %-100s\n" "$i" "${commands[$i]}"
  done | sort -n -k3
  exit 0
fi

# save custom command to user file
if [ "$1" == '-s' ] || [ "$1" == '--set' ]; then
  commands["$2"]="$3"
  declare -p commands >"$user_commands_file"
  exit 0
fi

# save custom command to user file
if [ "$1" == '-r' ] || [ "$1" == '--remove' ]; then
  unset commands["$2"]
  declare -p commands >"$user_commands_file"
  exit 0
fi

# back to first symfony project in current path
while [ ! -d ./bin ] || [ ! -f ./bin/console ] || ! grep -q "application = new Application" bin/console; do
  if [ $PWD == '/' ]; then
    echo "Please use this script in symfony project" 1>&2
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

echoCommand() {
  printf "bin/console %s" "$1"
  shift
  for i in "$@"; do
    case "$i" in
    *\ *)
      printf " '%s'" "$i"
      ;;
    *)
      printf " %s" "$i"
      ;;
    esac
  done
  printf "\n"
}

for i in "${!commands[@]}"; do
  if [ "$i" == "$short_command" ]; then
    IFS=';' read -ra array <<<"${commands[$i]}"
    for element in "${array[@]}"; do
      echoCommand "$element" "$@"
      ./bin/console "$element" "$@"
    done
    exit 0
  fi
done

echoCommand "$short_command" "$@"
./bin/console "$short_command" "$@"
exit 0
