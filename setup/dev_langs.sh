#!/bin/bash

# Install ruby
for version in 2.3.1 2.6.3; do
  echo "Installing ruby ${version}"
  rbenv install ${version}
  echo "Finished install ruby ${version}"
  echo "Installing bundler for ruby ${version}"
  rbenv global ${version}
  gem install bundler
  gem install neovim
  gem install fastri
  gem install rubocop
  gem install reek
  gem install ripper-tags
  gem install solargraph

  echo "Finished to install bundler for ruby ${version}"
done

## Set ruby global version as 2.6.3 for now
rbenv global 2.6.3

# Install node
for version in v6.9.2 v12.3.1; do
  echo "Installing node ${version}"
  ndenv install ${version}
  echo "Finished install node ${version}"
done

## Set node global version as v12.3.1 for now
ndenv global v12.3.1
npm install -g neovim

## Setup yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn -y

