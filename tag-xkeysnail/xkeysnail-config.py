import re
from xkeysnail.transform import *

# [Global modemap] Change modifier keys as in xmodmap
define_modmap({
    # Capslock -> Left ctrl
    Key.CAPSLOCK: Key.LEFT_CTRL,
})

define_keymap(lambda wm_class: wm_class not in ("Gnome-terminal", "rxvt"), {
    # Emacs like 
    ## Cursor
    K("C-b"): K("left"),
    K("C-f"): K("right"),
    K("C-p"): K("up"),
    K("C-n"): K("down"),

    K("M-b"): K("C-left"),
    K("M-f"): K("C-right"),

    K("C-a"): K("home"),
    K("C-e"): K("end"),
    K("C-k"): [K("Shift-end"), K("backspace")],
    K("C-d"): K("delete"),
    K("C-h"): K("backspace"),

    # LeftAlt -> Ctrl
    K("LM-a"): K("C-a"),
    K("LM-c"): K("C-c"),
    K("LM-f"): K("C-f"),
    K("LM-l"): K("C-l"),
    K("LM-n"): K("C-n"),
    K("LM-t"): K("C-t"),
    K("LM-v"): K("C-v"),
    K("LM-w"): K("C-w"),
    K("LM-x"): K("C-x"),
    K("LM-z"): K("C-z"),
    K("LM-Shift-z"): K("C-Shift-z")
}, "Default key mapping")

define_keymap(lambda wm_class: wm_class in ("Google-chrome"), {
    # Re-open closed tab
    K("M-Shift-t"): K("C-Shift-t"),

    # Previous-tab/Next-tab
    K("M-tab"): K("C-tab"),
    K("M-Shift-tab"): K("C-Shift-tab"),

    # actually these are vim insert mode bindings, but compatible with shell
    K("C-w"): [K("C-Shift-left"), K("delete")],

}, "Chrome keys")
