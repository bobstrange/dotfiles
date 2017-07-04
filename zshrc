# load zplug configuration
[[ -f $HOME/.zsh/zplug.zsh ]] && source $HOME/.zsh/zplug.zsh

# Load osx related configurations
if [ "$(uname)"=='Darwin' ]; then
  for zsh_source in $HOME/.zsh/configs/darwin/*.zsh; do
    source $zsh_source
  done
fi

# load custom configurations
for zsh_source in $HOME/.zsh/configs/*.zsh; do
  source $zsh_source
done


# load aliases
[[ -f $HOME/.aliases ]] && source $HOME/.aliases

autoload -U compinit
compinit


