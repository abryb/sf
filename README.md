# SymfonyScriptForBinConsole

Installation:

1. Globally
```bash
bash -c 'curl https://raw.githubusercontent.com/abryb/sf/master/sf -o /usr/local/bin/sf && chmod +x /usr/local/bin/sf'
```
2. For user
```bash
bash -c 'mkdir -p ~/.local/bin && curl https://raw.githubusercontent.com/abryb/sf/master/sf -o $HOME/.local/bin/sf && chmod +x $HOME/.local/bin/sf && if ! command -v sf; then echo 'PATH="$PATH:~/.local/bin"' >> ~/.profile && source ~/.profile;  fi'

```


Usage:
```bash
sf --help
```
