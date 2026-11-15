# nixGL (e.g. nixGLIntel ghostty) sets the library and Mesa driver paths, and
# ghostty's nixpkgs wrapper sets the GTK/GStreamer lookup paths, so the terminal
# finds its stack in the Nix store. Any shell it spawns inherits them, and they
# break Ubuntu binaries (e.g. /usr/lib/mozc/*, waydroid, GStreamer playback).
#
# Strip only the /nix/store/* entries so any user-set entries are preserved.
# Nix GUI apps set these again in their own wrappers; GL apps need nixGL.
# TERMINFO and GHOSTTY_* also point into the store but are meant for the shell.
typeset -a __kept
for __var in LD_LIBRARY_PATH GI_TYPELIB_PATH GIO_EXTRA_MODULES \
  GST_PLUGIN_SYSTEM_PATH_1_0 XDG_DATA_DIRS \
  LIBGL_DRIVERS_PATH LIBVA_DRIVERS_PATH GBM_BACKENDS_PATH __EGL_VENDOR_LIBRARY_FILENAMES; do
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
