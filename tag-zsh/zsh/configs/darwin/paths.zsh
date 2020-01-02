export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"

# For gnu core-utils
export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}

# For openssl
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

# For postgres
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"

# Vscode
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# openssl
export PATH="/usr/local/opt/openssl/bin:$PATH"

# asdf
test -s "$(brew --prefix asdf)" && source "$(brew --prefix asdf)/asdf.sh"
