# SymfonyScriptForBinConsole

Installation:
```bash
./install.sh
```
or 
```
cp sf.sh /usr/local/bin/sf
```


Usage:
```bash
# list all commands
sf -l
# add command
sf -s cc cache:clear
# execute it 
sf cc
# execute in env
sf cc -test # bin/console cache:clear --env=test
# use it from subdirectory of project
cd var/log
sf my-command
# remove command
sf -r my-old-command
```

Command are saved in home user directory in file ~/.config/symfonyHelper/commands.sh

