export PATH=$HOME/bin:/usr/local/bin:$PATH

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

if [ -f ~/.brew_github_api_token ]; then
 source ~/.brew_github_api_token
fi

if [ -f ~/.github_api_token ]; then
 source ~/.github_api_token
fi
