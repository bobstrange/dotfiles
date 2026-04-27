# nixGL (e.g. nixGLIntel ghostty) sets LD_LIBRARY_PATH so its child process can
# find Mesa/libglvnd from the Nix store. The child process inherits this to any
# shell it spawns, which then leaks into Ubuntu binaries (e.g. /usr/lib/mozc/*)
# and breaks them with glibc version mismatches.
#
# Strip only the /nix/store/* entries so any user-set entries are preserved.
# GUI apps that need GL should be wrapped with nixGL explicitly
# (e.g. `nixGLIntel neovide`).
if [[ "$LD_LIBRARY_PATH" == *"/nix/store/"* ]]; then
  typeset -a __ld_kept
  __ld_kept=("${(@s.:.)LD_LIBRARY_PATH}")
  __ld_kept=("${(@)__ld_kept:#/nix/store/*}")
  if (( ${#__ld_kept} )); then
    export LD_LIBRARY_PATH="${(j.:.)__ld_kept}"
  else
    unset LD_LIBRARY_PATH
  fi
  unset __ld_kept
fi
