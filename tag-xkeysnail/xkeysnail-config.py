import re
from xkeysnail.transform import *

# [Global modemap] Change modifier keys as in xmodmap
define_modmap({
    # Capslock -> Left ctrl
    Key.CAPSLOCK: Key.LEFT_CTRL,
})

define_keymap(lambda wm_class: wm_class not in ("Gnome-terminal", "rxvt", "Code"), {
    # Emacs like
    ## Cursor
    K("LC-b"): K("left"),
    K("LC-f"): K("right"),
    K("LC-p"): K("up"),
    K("LC-n"): K("down"),

    K("LM-b"): K("C-left"),
    K("LM-f"): K("C-right"),

    K("LC-a"): K("home"),
    K("LC-e"): K("end"),
    K("LC-k"): [K("Shift-end"), K("backspace")],
    K("LC-d"): K("delete"),
    K("LC-h"): K("backspace"),

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
}, "Emacs like")

define_keymap(lambda wm_class: wm_class in ("Code"), {
}, "VSCode keys")

define_keymap(lambda wm_class: wm_class in ("Google-chrome"), {
    # Re-open closed tab
    K("LM-Shift-t"): K("C-Shift-t"),

    # Previous-tab/Next-tab
    K("LM-tab"): K("C-tab"),
    K("LM-Shift-tab"): K("C-Shift-tab"),
    K("LM-Shift-BACKSLASH"): K("C-tab"),
    K("LM-Shift-RIGHT_BRACE"): K("C-Shift-tab"),

    # Reload
    K("LM-r"): K("RC-r")
}, "Chrome keys")
