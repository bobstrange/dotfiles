# nixGL (e.g. nixGLIntel ghostty) sets LD_LIBRARY_PATH, and ghostty's nixpkgs
# wrapper sets the GTK/GObject lookup paths, so the terminal finds its libraries
# in the Nix store. Any shell it spawns inherits them, and they break Ubuntu
# binaries with glibc/glib mismatches (e.g. /usr/lib/mozc/*, waydroid).
#
# Strip only the /nix/store/* entries so any user-set entries are preserved.
# Nix GUI apps set these again in their own wrappers.
typeset -a __kept
for __var in LD_LIBRARY_PATH GI_TYPELIB_PATH GIO_EXTRA_MODULES; do
  [[ "${(P)__var}" == *"/nix/store/"* ]] || continue
  __kept=("${(@s.:.)${(P)__var}}")
  __kept=("${(@)__kept:#/nix/store/*}")
  if (( ${#__kept} )); then
    export "$__var=${(j.:.)__kept}"
  else
    unset "$__var"
  fi
done
unset __var __kept
[[ "$GDK_PIXBUF_MODULE_FILE" == /nix/store/* ]] && unset GDK_PIXBUF_MODULE_FILE
