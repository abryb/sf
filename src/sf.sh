#!/bin/bash

self=$(basename $0)

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

# help
if [ "$1" == '-h' ] || [ "$1" == '--help' ] || [ "$1" == "" ]; then
  __usage="
Usage: $self [OPTIONS]
Running command: $self <alias> [<args>...] [COMMAND OPTIONS]
Options:
  -l, --list                   List all aliases commands.
  -s, --set <alias> <command>  Create new alias. E.g '-s do app:do:sth'
  --send-commands-to <host>    Send local command to host
  --copy-self-to <host>        Copy $self to host to ~/bin directory
"
  echo "$__usage"
  exit 0
fi

if [ "$1" == '-l' ] || [ "$1" == '--list' ]; then
  echo -e "\nList of commands: "
  for i in "${!commands[@]}"; do
    echo "$i" "${commands[$i]}"
  done | sort -n -k3 | column -t | sed 's/^/     /'
  echo ""
  exit 0
fi

# save command
if [ "$1" == '-s' ] || [ "$1" == '--set' ]; then
  commands["$2"]="$3"
  declare -p commands >"$user_commands_file"
  exit 0
fi

# remove command
if [ "$1" == '-r' ] || [ "$1" == '--remove' ]; then
  unset commands["$2"]
  declare -p commands >"$user_commands_file"
  exit 0
fi

# send commands to host
if [ "$1" == '--send-commands-to' ]; then
  commands_text=$(cat $user_commands_file)
  ssh "$2" "mkdir -p '$commands_file_dir' && echo '$commands_text' > '$commands_file'"
  exit 0
fi

# copy self to host
if [ "$1" == '--copy-self-to' ]; then
  scp "$0" "$2:~/bin/$self"
  exit 0
fi

# back to first symfony project in current path
while [ ! -f ./bin/console ] || ( ! grep -q "application = new Application" bin/console && ! grep -q "@sf root" bin/console); do
  if [ $PWD == '/' ]; then
    echo "Please use this script in symfony project" 1>&2
    exit 1
  fi
  cd ./..
done

# If parent directory also has bin/console script with "@sf root" annotation, go there
if [ ! $PWD == "/" ] && [ -f "./../bin/console" ] && grep -q "@sf root" ./../bin/console; then
   cd ..
fi

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
    another_argument=$(( $another_argument - 1))
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
      $self "$element" "$@"
    done
    exit 0
  fi
done

echoCommand "$short_command" "$@"
./bin/console "$short_command" "$@"
exit 0
