setup_zplug() {
  if [ `uname`=='Darwin' ]; then
    export ZPLUG_HOME=/usr/local/opt/zplug
  fi
  source $ZPLUG_HOME/init.zsh
}

setup_zplug
zplug "zsh-users/zsh-completions", defer:3

zplug load --verbose
