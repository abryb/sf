#!/bin/bash

set -e
declare -A commands

commands=(
  ['run']="server:run"
  ['start']="server:start"
  ['stop']="server:stop"
  ['ai']="assets:install"
  ['ais']="assets:install --symlink"
  ['ad']="assetic:dump"
  ['cc']="cache:clear"
  ['cpc']="cache:pool:clear"
  ['cw']="cache:warmup"
  ['cdr']="config:dump:reference"
  ['dc']="debug:container"
  ['dr']="debug:router"
  ['ded']="debug:event-dispatcher"
  ['rm']="router:match"
  ['pmd']="propel:migration:generate-diff"
  ['pmm']="propel:migration:migrate"
  ['pmb']="propel:model:build"
  ['pfl']="propel:fixtures:load"
  ['pfd']="propel:fixtures:dump"
  ['pfull']="propel:migration:generate-diff;propel:migration:migrate;propel:model:build"
  ['dmd']="doctrine:migrations:diff"
  ['dmm']="doctrine:migrations:migrate"
  ['dfull']="doctrine:migrations:diff;doctrine:migrations:migrate"
  ['dsu']="doctrine:schema:update"
  ['ddc']="doctrine:database:create"
  ['dd']="doctrine:database:import"
  ['fuc']="fos:user:create"
  ['fucp']="fos:user:change-password"
  ['fup']="fos:user:promote"
  ['tu']="translation:update"
)

# help
if [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
  for i in "${!commands[@]}"; do
    printf "    %-10s %-100s\n" "$i" "${commands[$i]}"
  done | sort -n -k3
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

