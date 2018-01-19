#!/bin/bash

ln -s ~/Dropbox/config/.ssh ~/.ssh
ln -s ~/Dropbox/config/github_token ~/.github_token
ln -s ~/Dropbox/config/aws ~/.aws

update_ssh_permission() {
  tmp="$(pwd)"
  cd ~/.ssh/
  ls | grep -vE "known_hosts|\.pub$|config" |xargs chmod 400
  cd ${tmp}
}

update_ssh_permission

ln -s ~/dotfiles/tag-git/gitconfig.$(uname) ~/.gitconfig.local
