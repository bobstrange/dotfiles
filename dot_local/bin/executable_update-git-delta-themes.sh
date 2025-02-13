#!/bin/bash

mkdir -p ~/.gitconfig.d/ &&
  curl -fsSL https://raw.githubusercontent.com/dandavison/delta/master/themes.gitconfig -o ~/.gitconfig.d/themes.gitconfig
