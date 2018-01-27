setup_zplug() {
  export ZPLUG_HOME=~/.zplug
  source $ZPLUG_HOME/init.zsh
}

setup_zplug

zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
zplug "zsh-users/zsh-completions", defer:3

zplug load --verbose
