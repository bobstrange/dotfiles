# Erlang/OTP build options for mise (kerl)
# Required on macOS to find Homebrew's OpenSSL and skip unused components
export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl) --without-javac --without-wx --without-odbc"
export KERL_BUILD_DOCS=no
