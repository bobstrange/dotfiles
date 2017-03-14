# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*(N-.); do
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/pre/*)
          :
          ;;
        "$_dir"/post/*)
          :
          ;;
        *)
          if [ -f $config ]; then
            . $config
          fi
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*(N-.); do
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nodejs
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=$HOME/.nodebrew/current/bin/npm:$PATH

# pyenv
eval "$(pyenv init -)"

# brew cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# direnv
eval "$(direnv hook zsh)"
 
# Homebrew
if [ -f ~/.brew_github_api_token ]; then
  source ~/.brew_github_api_token
fi

if [ -f ~/.github_api_token ]; then
  source ~/.github_api_token
fi

# go
export GOROOT=/usr/local/Cellar/go
export GOPATH="$HOME/.go"
export PATH="$GOPATH:$PATH"

