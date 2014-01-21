#!/bin/bash

# zshの設定
echo /usr/local/Cellar/zsh/*/bin/zsh | sudo tee -a /etc/shells
chpass -s /usr/local/Cellar/zsh/*/bin/zsh
