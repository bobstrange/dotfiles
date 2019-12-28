#!/bin/bash

if [ -x /usr/local/bin/xkeysnail ]; then
  xhost +SI:localuser:xkeysnail
  sudo -u xkeysnail DISPLAY=$DISPLAY /usr/local/bin/xkeysnail $HOME/dotfiles/tag-xkeysnail/xkeysnail-config.py
fi
