# SymfonyScriptForBinConsole

# ATTENTION!
This script use curl to send statistics.
If you don't want to do this delete/comment out line:
```bash
for i in "${!COMANDS[@]}"
do
    if [ "$i" == "$1" ] ; then
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
#        curl -s -d "username=$USER&score=$score" -X POST http://ssfbc.dev.hqnetworks.pl > /dev/null
        exit 0
    fi
done
```

Installation:
```bash
./install.sh
```

Usage:
```bash
# bin/console server:start
sf start 
# bin/console cache:clear --env=prod
sf cc prod
# bin/console cache:clear --env=prod --no-debug
sf cc prod --no-debug
# Running your command? No problem:
sf app:command-do-staff prod
```
You can user sf from any place in symfony project. Lets say you are editing files in vendor/example/example/dir/anotherdir/onemore (for fun). One simple 'sf cc' and job of clearing caches is done. 

```
run   = "server:run"  
start = "server:start"  
stop  = "server:stop"  
ai    = "assets:install"  
ais   = "assets:install --symlink"  
ad    = "assetic:dump"  
cc    = "cache:clear"  
cpc   = "cache:pool:clear"  
cw    = "cache:warmup"  
cdr   = "config:dump:reference"  
dc    = "debug:container"  
dr    = "debug:router"  
ded   = "debug:event-dispatcher"  
rm    = "router:match"  
pmd   = "propel:migration:generate-diff"  
pmm   = "propel:migration:migrate"  
pmb   = "propel:model:build"  
pfl   = "propel:fixtures:load"  
pfd   = "propel:fixtures:dump"  
pfull = "propel:migration:generate-diff;propel:migration:migrate;propel:model:build"  
dmd   = "doctrine:migrations:diff"  
dmm   = "doctrine:migrations:migrate"  
dfull = "doctrine:migrations:diff;doctrine:migrations:migrate"  
dsu   = "doctrine:schema:update"  
ddc   = "doctrine:database:create"  
dd    = "doctrine:database:import"  
fuc   = "fos:user:create"  
fucp  = "fos:user:change-password"  
fup   = "fos:user:promote"  
tu    = "translation:update"  
```
