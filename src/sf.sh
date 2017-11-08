#!/bin/bash

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
['fuc']="fos:user:crete"
['fucp']="fos:user:crete"
['fup']="fos:user:crete"
['tu']="translation:update"
)
if [ "$1" == '-h' ] || [ "$1" == '--help' ] ; then
    for i in "${!COMANDS[@]}"
    do
         printf "    %-10s %-100s\n" $i ${COMANDS[$i]}
    done | sort -n -k3
    exit 0
fi

if [ ! -d bin ] ; then
    echo "Please use this script in symfony main directory where bin directory is located"
    exit 1;
fi
if [ ! -f bin/console ] ; then
    echo "Please use this script in symfony main directory where I can run bin/console. Yes there is a bin directory but I need console file in it!"
    exit 1;
fi
if grep -Fxq "kernel = new AppKernel" bin/console ; then
    echo "Please use this script in symfony main directory where I can run bin/console. 'bin/console' it's not Symfony console. Don't try to cheat me!"
    exit 1;
fi

case $2 in
    'prod' )
        ARGS="--env=prod $3 $4 $5 $6"
        ;;
    'dev' )
        ARGS="--env=dev $3 $4 $5 $6"
        ;;
    'test' )
        ARGS="--env=test $3 $4 $5 $6"
        ;;
    *)
        ARGS="$2 $3 $4 $5 $6"
        ;;
esac

for i in "${!COMANDS[@]}"
do
    if [ "$i" == "$1" ] ; then
        IFS=';' read -ra array <<< "${COMANDS[$i]}"
        for element in "${array[@]}"
        do
             printf "bin/console $element $ARGS \n"
            ./bin/console $element $ARGS
            exit 0
        done
    fi
done
printf "bin/console $1 $ARGS \nS"
./bin/console $1 $ARGS
exit 0
