#!/bin/bash
set -e
declare -A COMANDS

COMANDS=(
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
['cgcc']="cache:clear; cache:clear --env=prod; chmod -R 777 var; echo 'Welcome to cogitech group.'"
)
if [ "$1" == '-h' ] || [ "$1" == '--help' ] ; then
    for i in "${!COMANDS[@]}"
    do
         printf "    %-10s %-100s\n" $i ${COMANDS[$i]}
    done | sort -n -k3
    exit 0
fi

while [ ! -d ./bin ] || [ ! -f ./bin/console ] || ! grep -q "application = new Application" bin/console ; do
    if [ $PWD == '/' ] ; then
        break;
    fi
    cd ./..
done
if [ ! -d ./bin ] || [ ! -f ./bin/console ] || ! grep -q "application = new Application" bin/console ; then
    echo "Please use this script in symfony project" 1>&2
    exit 1
fi
# Save first argument as our short command
SHORT_COMMAND=$1
# Replace any prod/dev/test argument with --env=prod/dev/test
ARGS="";
for a in "$@" ;do
    if [ "$1" == "$a" ] ; then
        continue
    fi

    case $a in
    'prod' )
        ARGS="$ARGS --env=prod"
        ;;
    'dev' )
        ARGS="$ARGS --env=dev"
        ;;
    'test' )
        ARGS="$ARGS --env=test"
        ;;
    *)
        ARGS="$ARGS $a"
        ;;
    esac
done

for i in "${!COMANDS[@]}"
do
    if [ "$i" == "$SHORT_COMMAND" ] ; then
        IFS=';' read -ra array <<< "${COMANDS[$i]}"
        score=0
        for element in "${array[@]}"
        do
            printf "bin/console $element $ARGS \n"
            ./bin/console $element $ARGS
            userCommand="sf $@"
            executedString="./bin/console $element $ARGS"
            executedString="$(echo -e "${executedString}" | sed -e 's/[[:space:]]*$//')"
            score=`expr $score + ${#executedString} - ${#userCommand}`
        done
        curl -s -d "username=$USER&score=$score" -X POST http://ssfbc.dev.hqnetworks.pl > /dev/null
        exit 0
    fi
done
printf "bin/console $SHORT_COMMAND $ARGS \n"
./bin/console $SHORT_COMMAND $ARGS
exit 0
