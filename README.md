# SymfonyScriptForBinConsole

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
```

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
