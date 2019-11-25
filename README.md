# SymfonyScriptForBinConsole

Installation:

1. Globally
```bash
sudo curl 'https://raw.githubusercontent.com/abryb/SymfonyScriptForBinConsole/master/src/sf.sh' -o /usr/local/bin/sf ;and sudo chmod +x /usr/local/bin/sf
```
2. For user
```bash
mkdir -p ~/bin && curl 'https://raw.githubusercontent.com/abryb/SymfonyScriptForBinConsole/master/src/sf.sh' -o ~/bin/sf && chmod +x ~/bin/sf
# If not already in PATH
echo 'PATH="$PATH:~/bin"' >> ~/.profile

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

Running multiple commands:
```console
foo@bar:~/myProject$ sf -s cc cache:clear
foo@bar:~/myProject$ sf -s ccw "cc;cache:warmup"
foo@bar:~/myProject$ sf ccw
bin/console cache:clear

 // Clearing the cache for the dev environment with debug true                                                          

                                                                                                                        
 [OK] Cache for the "dev" environment (debug=true) was successfully cleared.                                            
                                                                                                                        

bin/console cache:warmup

 // Warming up the cache for the dev environment with debug true                                                        

                                                                                                                        
 [OK] Cache for the "dev" environment (debug=true) was successfully warmed.                                             
                                                                                                                        
```

Command are saved in home user directory in file ~/.config/symfonyHelper/commands.sh

