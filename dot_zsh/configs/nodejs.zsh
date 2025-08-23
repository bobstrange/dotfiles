if command -v volta &> /dev/null && command -v pnpm &> /dev/null; then
  export PNPM_HOME="$HOME/.volta/bin"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
  export PNPM_CONFIG_STORE_DIR="$HOME/.volta/tools/image/pnpm/store"
  export PNPM_CONFIG_GLOBAL_DIR="$HOME/.volta/tools/image/pnpm/global"

  eval "$(pnpm completion zsh)"
fi
