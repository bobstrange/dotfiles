# load zplug configuration
[[ -f $HOME/.zsh/zplug.zsh ]] && source $HOME/.zsh/zplug.zsh

# Load osx related configurations

if [ "$(uname)" = 'Darwin' ]; then
  for zsh_source in $HOME/.zsh/configs/darwin/*.zsh; do
    source $zsh_source
  done
fi

# Load ubuntu related configurations

uname -v | grep -q "Ubuntu"
ubuntu=$?

if [ ${ubuntu} = 0 ]; then
  for zsh_source in $HOME/.zsh/configs/ubuntu/*.zsh; do
    source $zsh_source
  done
fi

# load custom configurations
for zsh_source in $HOME/.zsh/configs/*.zsh; do
  source $zsh_source
done


# load aliases
[[ -f $HOME/.aliases ]] && source $HOME/.aliases
for zsh_source in $HOME/.zsh/aliases/*.zsh; do
  source $zsh_source
done

autoload -U compinit
compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
