setup_zplug() {
  export ZPLUG_HOME=~/.zplug
  source $ZPLUG_HOME/init.zsh
}

setup_zplug
zplug "zsh-users/zsh-completions", defer:3

zplug load --verbose
