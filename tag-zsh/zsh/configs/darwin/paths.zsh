# For gnu core-utils
export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}

# Vscode
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# openssl
export PATH="/usr/local/opt/openssl/bin:$PATH"

# asdf
test -s "$(brew --prefix asdf)" && source "$(brew --prefix asdf)/asdf.sh"
