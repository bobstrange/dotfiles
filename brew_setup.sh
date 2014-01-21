#!/bin/bash

# homebrewのインストール
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# 更新が必要なものを確認する
brew doctor

# Blewfileに記述してあるアプリをインストール
brew bundle