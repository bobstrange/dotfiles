# For gnu core-utils
export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:${PATH}
export MANPATH=/opt/homebrew/opt/coreutils/libexec/gnuman:${MANPATH}

# Vscode
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# openssl
export PATH="/opt/homebrew/opt/openssl/bin:$PATH"

# asdf
test -s "$(brew --prefix asdf)" && source "$(brew --prefix asdf)/asdf.sh"
